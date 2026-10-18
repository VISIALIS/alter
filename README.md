# Alter

[![Latest release](https://img.shields.io/github/v/release/VISIALIS/alter)](https://github.com/VISIALIS/alter/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/VISIALIS/alter/total)](https://github.com/VISIALIS/alter/releases)

**Alter is an EVM Harness**: one environment for unified access to EVM chains and RPC access points, proof-backed understanding, and verifiable interaction.

You give it an address. Alter reads what that address is and keeps the on-chain proof beside the claim. When an action is wired, you inspect it before your wallet signs.

Three interfaces, one core, one audience each:

| Interface | Audience | You get |
| --- | --- | --- |
| **Flutter app** | End users | An address portrait in plain language |
| **CLI** (`alter-cli`) | Technical operators | The same portrait, scriptable and inspectable |
| **MCP** (`alter-mcp`) | Software agents | The same portrait as typed tools |

The [web app](https://app.alter-evm.com/) is the Flutter app opened in a browser: the same interface.

## Read → Prove → Act

**Read.** Start from an address, a transaction hash, a chain name, or an RPC URL. Alter recognizes standards and protocols and builds an address portrait: type, roles, relations, positions, and capabilities.

**Prove.** A useful claim stays tied to what was observed on-chain. Alter keeps an on-chain proof distinct from a presentation heuristic, and a per-chain capability distinct from a cross-chain summary.

**Act.** The portrait lists actions that are actually wired for that context. `transaction.prepare` (CLI and MCP) prepares an **unsigned** classic externally owned account payload and appends a public ERC-8021 attribution suffix. You sign in your wallet and broadcast through the RPC access point you chose. That preparation refuses ERC-4337 and ERC-5792 payloads. Alter does not hold keys.

## Quick start

The examples below use the USDT contract on Ethereum (`0xdAC17F958D2ee523a2206206994597C13D831ec7`), a public token contract.

Skip `brew tap` or `scoop bucket add` if that source is already configured.

### Flutter app — end users

**macOS (Homebrew)**

```bash
brew tap VISIALIS/alter
brew install --cask alter
open -a Alter
```

**Windows (Scoop)**

```powershell
scoop bucket add visialis https://github.com/VISIALIS/scoop-alter
scoop install visialis/alter
alter
```

**Current release assets**

Desktop archives are on the [latest release](https://github.com/VISIALIS/alter/releases/latest). The release badge at the top of this page tracks that release. Filenames embed the version, so this page does not pin one:

- macOS (Apple silicon and Intel): `Alter-<version>-macOS-Notarized.dmg`. Open the disk image, move `Alter.app` into Applications, then open it.
- Windows x64: `Alter-<version>-windows.zip` (the archive root contains `alter.exe`). ARM64: `Alter-<version>-windows-arm64.zip`.
- Linux x64: `alter-<version>-linux.tar.gz` (the archive root contains the `alter` binary). There is no Linux ARM64 desktop build.

**Web** — no install: [app.alter-evm.com](https://app.alter-evm.com/).

**iOS and Android.** Native apps are in private beta and are not on the public stores. Use the web app on a phone.

### CLI — technical operators

**macOS and Linux (Homebrew)**

```bash
brew tap VISIALIS/alter
brew install alter-cli
alter-cli 0xdAC17F958D2ee523a2206206994597C13D831ec7
```

On Linux, the same formula installs the x64 and ARM64 binaries published on this repository.

**Windows (Scoop)**

```powershell
scoop bucket add visialis https://github.com/VISIALIS/scoop-alter
scoop install visialis/alter-cli
alter-cli 0xdAC17F958D2ee523a2206206994597C13D831ec7
```

**Other platforms (current release)**

macOS and Linux, from the installer in this repository (also at `https://www.alter-evm.com/install.sh`). It downloads `alter-cli-<os>-<arch>.tar.gz` and `alter-mcp-<os>-<arch>.tar.gz` from the latest release (`macos` or `linux`, `x64` or `arm64`):

```bash
curl -fsSL https://www.alter-evm.com/install.sh | bash
alter-cli --version
alter-cli 0xdAC17F958D2ee523a2206206994597C13D831ec7
```

Windows (installer hosted at `https://www.alter-evm.com/install.ps1`). It downloads `alter-cli-windows-x64.exe` or `alter-cli-windows-arm64.exe` from the latest release and installs it as `alter-cli.exe`:

```powershell
iwr https://www.alter-evm.com/install.ps1 -useb | iex
alter-cli --version
alter-cli 0xdAC17F958D2ee523a2206206994597C13D831ec7
```

Direct names on the [latest release](https://github.com/VISIALIS/alter/releases/latest): `alter-cli-macos-arm64.tar.gz`, `alter-cli-macos-x64.tar.gz`, `alter-cli-linux-arm64.tar.gz`, `alter-cli-linux-x64.tar.gz`, `alter-cli-windows-arm64.exe`, `alter-cli-windows-x64.exe`.

### MCP — software agents

The server speaks MCP over stdin/stdout. The binary name is `alter-mcp`. It takes no required arguments.

**macOS and Linux (Homebrew)**

```bash
brew tap VISIALIS/alter
brew install alter-mcp
alter-mcp --version
```

**Windows (Scoop)** — or `install.ps1` in the CLI section, which installs `alter-mcp.exe` next to `alter-cli.exe`. The latest-release assets are `alter-mcp-windows-x64.exe` and `alter-mcp-windows-arm64.exe`.

```powershell
scoop bucket add visialis https://github.com/VISIALIS/scoop-alter
scoop install visialis/alter-mcp
alter-mcp --version
```

**Other platforms.** `install.sh` and `install.ps1` in the CLI section install `alter-mcp` together with `alter-cli`. Confirm with `alter-mcp --version`.

#### Claude Desktop

macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`  
Windows: `%APPDATA%\Claude\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "alter": {
      "command": "alter-mcp",
      "args": []
    }
  }
}
```

#### Cursor

Project file `.cursor/mcp.json`, or user file `~/.cursor/mcp.json` (`%USERPROFILE%\.cursor\mcp.json` on Windows):

```json
{
  "mcpServers": {
    "alter": {
      "command": "alter-mcp",
      "args": []
    }
  }
}
```

If the client does not search `PATH`, set `command` to the absolute path of `alter-mcp` (`alter-mcp.exe` on Windows). Restart the client after saving. A first call, as printed by `alter-mcp --help`:

```text
address.add({ "address": "0xdAC17F958D2ee523a2206206994597C13D831ec7" })
```

## Accountants and tax professionals

On the CLI and MCP, Alter can qualify an address, build a closed-period activity statement (`address.statement`), and translate that statement into the accounting or tax vocabulary of a jurisdiction you name (`address.statement.translate`, register `accounting` or `tax`). Each item stays tied to the on-chain evidence and to the versioned professional source that justifies the term, or it stays undetermined.

Alter stops at that translated, proven history. It does not choose your jurisdiction, compute a tax base or a tax, post a final journal entry, file a return, or give professional advice. This translation is not in the Flutter app.

## Your reading, without a hosted interpreter

Alter restores your ability to read the chain yourself. The sovereignty is yours: Alter lifts the hosted interpreter that stood between you and the chain, and it does not keep your keys.

You choose the chain and the RPC access point. A signed transaction is sealed by your key. The access point can refuse or delay it. It cannot rewrite it.

## Screenshots

> **PLACEHOLDER — screenshot not attached yet.** Address portrait in the Flutter app: type, roles, capabilities, and the actions wired for that address. Replace this box with a capture before treating the README as illustrated.

> **PLACEHOLDER — screenshot not attached yet.** `alter-cli` classifying `0xdAC17F958D2ee523a2206206994597C13D831ec7`, with the on-chain proof visible next to the portrait.

> **PLACEHOLDER — GIF not attached yet.** One pass through Read → Prove → Act on a single address, in the app or the CLI. Replace this box with a short recording.

## This repository

This repository publishes Alter releases and public issues. Source development lives elsewhere.

| Channel | What it installs |
| --- | --- |
| [Releases](https://github.com/VISIALIS/alter/releases) | Desktop, CLI, and MCP binaries |
| [VISIALIS/homebrew-alter](https://github.com/VISIALIS/homebrew-alter) | `brew` formulas and the macOS cask, tracking the latest release |
| [VISIALIS/scoop-alter](https://github.com/VISIALIS/scoop-alter) | Windows Scoop packages, tracking the latest release on this repository |
| [app.alter-evm.com](https://app.alter-evm.com/) | Flutter app in the browser |

Questions and bugs: [open an issue](https://github.com/VISIALIS/alter/issues).
