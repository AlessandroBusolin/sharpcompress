using System;
using System.Collections.Generic;
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
    /// <param name="isLzma2">True for LZMA2, false for LZMA.</param>
    /// <param name="encoderProperties">LZMA encoder properties (null for defaults).</param>
    public PackedStream Compress(
        Stream inputStream,
        bool isLzma2,
        LzmaEncoderProperties? encoderProperties = null
    )
    {
        encoderProperties ??= new LzmaEncoderProperties(eos: !isLzma2);

        var outStartOffset = outputStream.Position;

        // Wrap the output stream in CRC calculator
        using var outCrcStream = new Crc32Stream(outputStream);

        byte[] properties;

        if (isLzma2)
        {
            // LZMA2: use Lzma2EncoderStream for chunk-based framing
            using var lzma2Stream = new Lzma2EncoderStream(
                outCrcStream,
                encoderProperties.DictionarySize,
                encoderProperties.NumFastBytes
            );

            // Copy input through the LZMA2 encoder while computing input CRC
            CopyWithCrc(inputStream, lzma2Stream, out var inputCrc2, out var inputSize2);

            // Flush/finalize (writes remaining buffer + end marker)
            lzma2Stream.Dispose();

            var compressedSize2 = (ulong)(outputStream.Position - outStartOffset);
            var uncompressedSize2 = (ulong)inputSize2;
            var outputCrc2 = outCrcStream.Crc;

            properties = lzma2Stream.Properties;

            return BuildPackedStream(
                isLzma2: true,
                properties,
                compressedSize2,
                uncompressedSize2,
                inputCrc2,
                outputCrc2
            );
        }

        // LZMA: existing path
        using var lzmaStream = LzmaStream.Create(encoderProperties, false, outCrcStream);
        properties = lzmaStream.Properties;

        // Copy input through the LZMA encoder while computing input CRC
        CopyWithCrc(inputStream, lzmaStream, out var inputCrc, out var inputSize);

        // Flush/finalize the LZMA encoder (writes remaining compressed data)
        lzmaStream.Dispose();

        var compressedSize = (ulong)(outputStream.Position - outStartOffset);
        var uncompressedSize = (ulong)inputSize;
        var outputCrc = outCrcStream.Crc;

        return BuildPackedStream(
            isLzma2: false,
            properties,
            compressedSize,
            uncompressedSize,
            inputCrc,
            outputCrc
        );
    }

    private static PackedStream BuildPackedStream(
        bool isLzma2,
        byte[] properties,
        ulong compressedSize,
        ulong uncompressedSize,
        uint inputCrc,
        uint? outputCrc
    )
    {
        var methodId = isLzma2 ? CMethodId.K_LZMA2 : CMethodId.K_LZMA;

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
    /// </summary>
    private static void CopyWithCrc(Stream source, Stream destination, out uint crc, out long bytesRead)
    {
        var crcValue = Crc32Stream.DEFAULT_SEED;
        var table = InitCrcTable();
        var buffer = new byte[81920];
        long totalRead = 0;

        int read;
        while ((read = source.Read(buffer, 0, buffer.Length)) > 0)
        {
            // Update CRC
            for (var i = 0; i < read; i++)
            {
                crcValue = (crcValue >> 8) ^ table[(crcValue ^ buffer[i]) & 0xFF];
            }

            destination.Write(buffer, 0, read);
            totalRead += read;
        }

        crc = ~crcValue;
        bytesRead = totalRead;
    }

    private static uint[] InitCrcTable()
    {
        var table = new uint[256];
        for (var i = 0; i < 256; i++)
        {
            var entry = (uint)i;
            for (var j = 0; j < 8; j++)
            {
                entry = (entry & 1) == 1 ? (entry >> 1) ^ Crc32Stream.DEFAULT_POLYNOMIAL : entry >> 1;
            }
            table[i] = entry;
        }
        return table;
    }
}
