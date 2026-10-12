# Framework 13 microphone workaround for CachyOS

A small native WirePlumber configuration for the Framework Laptop 13 with an AMD Ryzen AI 5 340. It exposes the working ALC285 internal microphone, hides the ACP PDM input that produced saturated samples on the tested laptop, and sets a 25% starting input level. Later volume changes are remembered normally.

The configuration uses CachyOS's existing PipeWire and WirePlumber services. It adds no daemon, polling, audio filters, or kernel-module blacklist.

## Tested hardware and software

| Component | Tested version |
| --- | --- |
| Laptop | Framework Laptop 13, AMD Ryzen AI 5 340 |
| Mainboard | FRANMGCP05 |
| Webcam module | Framework Webcam Module, 2nd Gen |
| BIOS | 04.02 |
| Distribution | CachyOS |
| Kernel | 7.2.9-2-cachyos |
| WirePlumber | 0.5.18 |
| PipeWire | 1.6.9 |
| ALSA UCM configuration | 1.2.16.1 |

The installer checks the distribution and mainboard before writing anything.

## Install

```sh
git clone https://github.com/phofueled/framework-audio-fix.git
cd framework-audio-fix
sudo ./install.sh
systemctl --user restart wireplumber
```

Open **System Settings → Sound**, choose **Internal Microphone**, and set its input level to **25%**. Make a short recording and adjust the level for your voice. A previously saved volume can override the new starting level.

The system configuration is installed at `/etc/wireplumber/wireplumber.conf.d/51-framework-internal-mic.conf`. Reinstalling an unchanged configuration skips the write. Changed configurations are replaced atomically, and an existing configuration is backed up under `/var/lib/framework-audio/pre-install/`.

## Remove

```sh
sudo rm /etc/wireplumber/wireplumber.conf.d/51-framework-internal-mic.conf
systemctl --user restart wireplumber
```

This restores the distribution's normal microphone routing. Volume preferences remain saved in WirePlumber.

## Earlier work

This configuration packages an established workaround for CachyOS. Earlier reports and fixes include:

- [Arch/Framework community workaround, October 8, 2025](https://community.frame.work/t/laptop13-ryzen-ai-340-internal-mic-in-fedora42-doesnt-work/75748/8).
- [NixOS hardware workaround, merged January 25, 2026](https://github.com/NixOS/nixos-hardware/pull/1744).
- [Framework's tracking issue and other userspace workarounds](https://github.com/FrameworkComputer/SoftwareFirmwareIssueTracker/issues/166).

## License

BSD 3-Clause; see [LICENSE](LICENSE).
