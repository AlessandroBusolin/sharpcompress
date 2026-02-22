using System;
using System.IO;
using System.Threading;
using System.Threading.Tasks;

namespace SharpCompress.Writers.SevenZip;

public partial class SevenZipWriter
{
    /// <summary>
    /// Asynchronously writes a file entry to the 7z archive.
    /// Note: LZMA compression itself is synchronous; async is used for stream copying.
    /// </summary>
    public override ValueTask WriteAsync(
        string filename,
        Stream source,
        DateTime? modificationTime,
        CancellationToken cancellationToken = default
    )
    {
        cancellationToken.ThrowIfCancellationRequested();
        Write(filename, source, modificationTime);
        return new ValueTask();
    }

    /// <summary>
    /// Asynchronously writes a directory entry to the 7z archive.
    /// </summary>
    public override ValueTask WriteDirectoryAsync(
        string directoryName,
        DateTime? modificationTime,
        CancellationToken cancellationToken = default
    )
    {
        cancellationToken.ThrowIfCancellationRequested();
        WriteDirectory(directoryName, modificationTime);
        return new ValueTask();
    }
}
