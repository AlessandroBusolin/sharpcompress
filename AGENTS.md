---
description: 'Guidelines for building SharpCompress - A C# compression library'
applyTo: '**/*.cs'
---

# SharpCompress Development

## About SharpCompress
SharpCompress is a pure C# compression library supporting multiple archive formats (Zip, Tar, GZip, BZip2, 7Zip, Rar, LZip, XZ, ZStandard) for .NET Framework 4.62, .NET Standard 2.1, .NET 6.0, and .NET 8.0. The library provides both seekable Archive APIs and forward-only Reader/Writer APIs for streaming scenarios.

## C# Instructions
- Always use the latest version C#, currently C# 13 features.
- Write clear and concise comments for each function.
- Follow the existing code style and patterns in the codebase.

## General Instructions
- Make only high confidence suggestions when reviewing code changes.
- Write code with good maintainability practices, including comments on why certain design decisions were made.
- Handle edge cases and write clear exception handling.
- For libraries or external dependencies, mention their usage and purpose in comments.
- Preserve backward compatibility when making changes to public APIs.

## Naming Conventions

- Follow PascalCase for component names, method names, and public members.
- Use camelCase for private fields and local variables.
- Prefix interface names with "I" (e.g., IUserService).

## Code Formatting

- Follow the formatting rules defined in `.editorconfig`
- Use 4 spaces for indentation
- Use UTF-8 encoding
- Insert final newline in files
- Trim trailing whitespace
- Configure your IDE to respect `.editorconfig` settings (most modern IDEs do this automatically)
- Consistent code formatting is enforced through `.editorconfig` to maintain code quality across the project

## Project Setup and Structure

- The project targets multiple frameworks: .NET Framework 4.62, .NET Standard 2.1, .NET 6.0, and .NET 8.0
- Main library is in `src/SharpCompress/`
- Tests are in `tests/SharpCompress.Test/`
- Performance tests are in `tests/SharpCompress.Performance/`
- Test archives are in `tests/TestArchives/`
- Build project is in `build/`
- Use `dotnet build` to build the solution
- Use `dotnet test` to run tests
- Solution file: `SharpCompress.sln`

## Nullable Reference Types

- Declare variables non-nullable, and check for `null` at entry points.
- Always use `is null` or `is not null` instead of `== null` or `!= null`.
- Trust the C# null annotations and don't add null checks when the type system says a value cannot be null.

## SharpCompress-Specific Guidelines

### Supported Formats
SharpCompress supports multiple archive and compression formats:
- **Archive Formats**: Zip, Tar, 7Zip, Rar (read-only)
- **Compression**: DEFLATE, BZip2, LZMA/LZMA2, PPMd, ZStandard (decompress only), Deflate64 (decompress only)
- **Combined Formats**: Tar.GZip, Tar.BZip2, Tar.LZip, Tar.XZ, Tar.ZStandard
- See FORMATS.md for complete format support matrix

### Stream Handling Rules
- **Disposal**: As of version 0.21, SharpCompress closes wrapped streams by default
- Use `ReaderOptions` or `WriterOptions` with `LeaveStreamOpen = true` to control stream disposal
- Use `NonDisposingStream` wrapper when working with compression streams directly to prevent disposal
- Always dispose of readers, writers, and archives in `using` blocks
- For forward-only operations, use Reader/Writer APIs; for random access, use Archive APIs

### Async/Await Patterns
- All I/O operations support async/await with `CancellationToken`
- Async methods follow the naming convention: `MethodNameAsync`
- Key async methods:
  - `WriteEntryToAsync` - Extract entry asynchronously
  - `WriteAllToDirectoryAsync` - Extract all entries asynchronously
  - `WriteAsync` - Write entry asynchronously
  - `WriteAllAsync` - Write directory asynchronously
  - `OpenEntryStreamAsync` - Open entry stream asynchronously
- Always provide `CancellationToken` parameter in async methods

### Archive APIs vs Reader/Writer APIs
- **Archive API**: Use for random access with seekable streams (e.g., `ZipArchive`, `TarArchive`)
- **Reader API**: Use for forward-only reading on non-seekable streams (e.g., `ZipReader`, `TarReader`)
- **Writer API**: Use for forward-only writing on streams (e.g., `ZipWriter`, `TarWriter`)
- 7Zip only supports Archive API due to format limitations

### Tar-Specific Considerations
- Tar format requires file size in the header
- If no size is specified to TarWriter and the stream is not seekable, an exception will be thrown
- Tar combined with compression (GZip, BZip2, LZip, XZ) is supported

### Zip-Specific Considerations
- Supports Zip64 for large files (seekable streams only)
- Supports PKWare and WinZip AES encryption
- Multiple compression methods: None, Shrink, Reduce, Implode, DEFLATE, Deflate64, BZip2, LZMA, PPMd
- Encrypted LZMA is not supported

### Performance Considerations
- For large files, use Reader/Writer APIs with non-seekable streams to avoid loading entire file in memory
- Leverage async I/O for better scalability
- Consider compression level trade-offs (speed vs. size)
- Use appropriate buffer sizes for stream operations

## Testing

- Always include test cases for critical paths of the application.
- Test with multiple archive formats when making changes to core functionality.
- Include tests for both Archive and Reader/Writer APIs when applicable.
- Test async operations with cancellation tokens.
- Do not emit "Act", "Arrange" or "Assert" comments.
- Copy existing style in nearby files for test method names and capitalization.
- Use test archives from `tests/TestArchives` directory for consistency.
- Test stream disposal and `LeaveStreamOpen` behavior.
- Test edge cases: empty archives, large files, corrupted archives, encrypted archives.
