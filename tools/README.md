# Development Tools

Ten katalog zawiera narzędzia używane podczas tworzenia integracji.

## deploy.ps1

Kopiuje integrację do lokalnego Home Assistanta.

## clean.ps1

Czyści pliki tymczasowe projektu.

## release.ps1

Tworzy release projektu na GitHub.

## config.ps1

Wspólna konfiguracja wszystkich skryptów.

Requirements

- Git
- Python 3.13+
- OpenSSH
- rsync

Both `ssh` and `rsync` must be available in PATH.