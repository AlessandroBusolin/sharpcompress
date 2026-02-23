using System;
using System.IO;
using SharpCompress.Common;
using SharpCompress.Compressors.LZMA;
using SharpCompress.Crypto;

namespace SharpCompress.Common.SevenZip;

/// <summary>
/// Result of compressing a stream - contains folder metadata, compressed sizes, and CRCs.
/// </summary>
internal sealed class PackedStream
{
    public CFolder Folder { get; init; } = new();
    public ulong[] Sizes { get; init; } = [];
    public uint?[] CRCs { get; init; } = [];
}

/// <summary>
/// Compresses a single input stream using LZMA or LZMA2, writing compressed output
/// to the archive stream. Builds the CFolder metadata describing the compression.
/// Uses SharpCompress's existing LzmaStream encoder.
/// </summary>
internal sealed class SevenZipStreamsCompressor(Stream outputStream)
{
    /// <summary>
    /// Compresses the input stream to the output stream using the specified method.
    /// Returns a PackedStream containing folder metadata, compressed size, and CRCs.
    /// </summary>
    /// <param name="inputStream">Uncompressed data to compress.</param>
    /// <param name="compressionType">Compression method (LZMA or LZMA2).</param>
    /// <param name="encoderProperties">LZMA encoder properties (null for defaults).</param>
    public PackedStream Compress(
        Stream inputStream,
        CompressionType compressionType,
        LzmaEncoderProperties? encoderProperties = null
    )
    {
        var isLzma2 = compressionType == CompressionType.LZMA2;
        encoderProperties ??= new LzmaEncoderProperties(eos: true);

        var outStartOffset = outputStream.Position;
        var inStartOffset = inputStream.CanSeek ? inputStream.Position : 0L;

        // Wrap the output stream in CRC calculator
        using var outCrcStream = new Crc32Stream(outputStream);

        // Create LZMA encoder writing to CRC-wrapped output
        using var lzmaStream = LzmaStream.Create(encoderProperties, isLzma2, outCrcStream);
        var properties = lzmaStream.Properties;

        // Copy input through the LZMA encoder while computing input CRC
        uint inputCrc;
        long inputSize;
        CopyWithCrc(inputStream, lzmaStream, out inputCrc, out inputSize);

        // Flush/finalize the LZMA encoder (writes remaining compressed data)
        lzmaStream.Dispose();

        var compressedSize = (ulong)(outputStream.Position - outStartOffset);
        var uncompressedSize = (ulong)inputSize;
        var outputCrc = outCrcStream.Crc;

        // Build method ID
        var methodId = isLzma2 ? CMethodId.K_LZMA2 : CMethodId.K_LZMA;

        // Build folder metadata
        var folder = new CFolder();
        folder._coders.Add(
            new CCoderInfo
            {
                _methodId = methodId,
                _numInStreams = 1,
                _numOutStreams = 1,
                _props = properties,
            }
        );
        folder._packStreams.Add(0);
        folder._unpackSizes.Add((long)uncompressedSize);
        folder._unpackCrc = inputCrc;

        return new PackedStream
        {
            Folder = folder,
            Sizes = [compressedSize],
            CRCs = [outputCrc],
        };
    }

    /// <summary>
    /// Copies data from source to destination while computing CRC32 of the source data.
    /// Uses Crc32Stream.Compute for CRC calculation to avoid duplicating the table/algorithm.
    /// </summary>
    private static void CopyWithCrc(Stream source, Stream destination, out uint crc, out long bytesRead)
    {
        var seed = Crc32Stream.DEFAULT_SEED;
        var buffer = new byte[81920];
        long totalRead = 0;

        int read;
        while ((read = source.Read(buffer, 0, buffer.Length)) > 0)
        {
            // Crc32Stream.Compute returns ~CalculateCrc(table, seed, data),
            // so passing ~result as next seed chains correctly.
            seed = ~Crc32Stream.Compute(Crc32Stream.DEFAULT_POLYNOMIAL, seed, buffer.AsSpan(0, read));
            destination.Write(buffer, 0, read);
            totalRead += read;
        }

        crc = ~seed;
        bytesRead = totalRead;
    }
}
