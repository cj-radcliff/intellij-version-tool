# IntelliJ Version Tool

A Dart command-line tool that fetches JetBrains product release information and generates an easy-to-read Markdown table.

## Features

- Fetches release data directly from JetBrains API.
- Generates formatted Markdown tables.
- Sorts releases by recency (most recent first).
- Customizable product codes (e.g., IU, IC, PS, GO).
- Customizable release types (e.g., release, eap, beta).
- Supports dynamic column selection, including a "show all" mode.

## Installation

1. Ensure you have the [Dart SDK](https://dart.dev/get-dart) installed.
2. Clone this repository or navigate to the project folder.
3. Install dependencies:
   ```powershell
   dart pub get
   ```

## Usage

Run the tool using `dart run`:

```powershell
dart run bin/intellij_version_tool.dart [options] <output_file_path>
```

### Options

| Option | Abbreviation | Default | Description |
| --- | --- | --- | --- |
| `--code` | `-c` | `IU` | The product code (e.g., `IU` for Ultimate, `IC` for Community, `PS` for PhpStorm). |
| `--type` | `-t` | `release` | The release type (e.g., `release`, `eap`, `beta`). |
| `--columns` | `-C` | (none) | Comma-separated list of additional columns to display (or `all`). |
| `--help` | `-h` | | Show usage information. |

### Examples

**Basic usage (IntelliJ IDEA Ultimate releases):**
```powershell
dart run bin/intellij_version_tool.dart releases.md
```

**Fetch IntelliJ IDEA Community EAP releases:**
```powershell
dart run bin/intellij_version_tool.dart --code=IC --type=eap ic_eap.md
```

**Add specific extra columns (e.g., majorVersion and notesLink):**
```powershell
dart run bin/intellij_version_tool.dart --columns=majorVersion,notesLink output.md
```

**Generate a report with ALL available data columns:**
```powershell
dart run bin/intellij_version_tool.dart --columns=all full_report.md
```

## Core Columns

By default, the table always includes:
- `version`
- `build`
- `date`
