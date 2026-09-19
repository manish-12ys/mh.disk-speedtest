# My Disk speed test — `mh.disk-speedtest`

> Aston Martin Racing-inspired storage benchmark panel for [Omarchy](https://omarchy.org/). Cloned from `omarchy.disk-speedtest` and restyled via `AmrSpeedOverlay` (dual gauge cluster).

Live **READ** / **WRITE** dials in **MB/s**, titled with the disk model under test. One `omarchy-disk-speedtest` run streams both phases and cleans up on dismiss.

![AMR // STORAGE](preview.png)

## Features
- Dual dials: READ | WRITE with adaptive scale ` [500, 1000, 2500, 5000, 10000, 15000] MB/s`
- AMR housing: racing-green / carbon / lime accent, `AMR // STORAGE` header
- Streams `disk <model>`, `read <MB/s>`, `write <MB/s>` from `omarchy-disk-speedtest`
- Run Again / Esc to dismiss (stops the backend process)

## Install

```bash
# from GitHub via Omarchy plugin manager (once published)
omarchy plugin add https://github.com/manish-12ys/mh.disk-speedtest

# or clone manually
git clone https://github.com/manish-12ys/mh.disk-speedtest.git ~/.config/omarchy/plugins/mh.disk-speedtest
omarchy plugin enable mh.disk-speedtest
omarchy restart shell
```

Direct clone (development):

```bash
git clone https://github.com/manish-12ys/mh.disk-speedtest ~/.config/omarchy/plugins/mh.disk-speedtest
```

## Usage

```bash
# summon panel (starts a fresh run)
omarchy-shell shell summon mh.disk-speedtest
# alternative – original summon name still described in stock docs:
omarchy-shell shell summon omarchy.disk-speedtest
```

Keys inside overlay: `Esc` dismiss, `Enter` Run Again (when idle).

## Requirements
- Omarchy + Quickshell
- Backend: `omarchy-disk-speedtest` (ships with Omarchy: `/usr/share/omarchy/bin/omarchy-disk-speedtest`)

## Manifest
- `id: mh.disk-speedtest` (clonedFrom `omarchy.disk-speedtest`)
- `kinds: [panel]` → `Panel.qml` + `AmrSpeedOverlay.qml` (430-line shared gauge)

## License
MIT — see `LICENSE`
