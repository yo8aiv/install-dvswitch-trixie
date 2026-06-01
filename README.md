# 📡 DVSwitch Server for Debian Trixie (v1.0)

```text
`..      `..    `....                      `.       `..`..         `..
 `..    `..   `..    `..      `.          `. ..     `.. `..       `.. 
  `.. `..   `..        `.. `..  `..      `.  `..    `..  `..     `..  
    `..     `..        `..`..     `.    `..   `..   `..   `..   `..   
    `..     `..        `..  `.. `.     `...... `..  `..    `.. `..    
    `..       `..     `.. `..     `.. `..       `.. `..     `....     
    `..         `....       `....    `..         `..`..      `..      
                                                                                                                 
     D e b i a n   T r i x i e  D V - S w i t c h    I n s t a l l
     C r e a t e d   a n d   O p t i m i z e d   by   Y O 8 A I V
```

[![Debian Trixie](https://img.shields.io/badge/OS-Debian_13_Trixie-d70a53?style=for-the-badge&logo=debian)](https://www.debian.org/)
[![License](https://img.shields.io/badge/License-ISC-blue?style=for-the-badge)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Production_Ready-brightgreen?style=for-the-badge)]()

> **⚠️ Important:** This script compiles **MMDVM_Bridge**, **Analog_Bridge**, and **md380-emu** from source because official binaries are not yet available for Debian 13.

---

## 🗺️ Architecture Overview

This installation creates a complete DVSwitch bridge connecting DMR networks to analog systems (AllStar/USRP).

```text
┌─────────────────────────────────────────────────────────────────┐
│                      DVSwitch Server Stack                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌──────────────┐      ┌──────────────┐      ┌──────────────┐  │
│   │  MMDVM_      │─────▶│   Analog     │─────▶│   md380-    │  │
│   │  Bridge      │      │   Bridge     │      │   emu        │  │
│   │              │      │              │      │              │  │
│   │ • DMR Net    │      │ • USRP       │      │ • AMBE       │  │
│   │ • P25 Net    │      │ • Audio      │      │ • Transcode  │  │
│   │ • YSF Net    │      │ • Routing    │      │ • DMR Voice  │  │
│   └──────┬───────┘      └──────┬───────┘      └──────┬───────┘  │
│          │                     │                     │          │
│          ▼                     ▼                     ▼          │
│   ┌──────────────┐      ┌──────────────┐      ┌──────────────┐  │
│   │ BrandMeister │      │ AllStarLink  │      │ Audio Stream │  │
│   │ DMR+         │      │ Asterisk     │      │ (USRP)       │  │
│   │ Master       │      │ Node         │      │              │  │
│   └──────────────┘      └──────────────┘      └──────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 🔗 Data Flow
1. **MMDVM_Bridge**: Connects to DMR Master Servers (BrandMeister/DMR+) and receives digital voice frames.
2. **Analog_Bridge**: Converts digital frames to analog audio (USRP protocol) and routes traffic.
3. **md380-emu**: Provides software AMBE transcoding for DMR voice compression/decompression.

---

## 🚀 Quick Start

### Prerequisites
*   **OS**: Debian 13 (Trixie) - *Clean install recommended*
*   **Architecture**: `amd64` (PC) or `arm64` (Pi 3/4/5 64-bit)
*   **Access**: Root or `sudo` privileges
*   **Network**: Static IP recommended for server stability

### Installation Steps

#### 1️⃣ Download the Script
```bash
cd ~
wget https://raw.githubusercontent.com/YOUR_USERNAME/dvswitch-trixie/main/install-dvswitch-trixie.sh
chmod +x install-dvswitch-trixie.sh
```

#### 2️⃣ Run the Installer
```bash
sudo ./install-dvswitch-trixie.sh
```
⏳ *Compilation takes approximately 5-10 minutes depending on hardware.*

#### 3️⃣ Configure Your Node
Edit the configuration files with your DMR ID and Master Server details:
```bash
nano /opt/MMDVM_Bridge/MMDVM_Bridge.ini
nano /opt/Analog_Bridge/Analog_Bridge.ini
nano /opt/md380-emu/md380-emu.ini
```

#### 4️⃣ Restart Services
```bash
sudo systemctl restart mmdvm_bridge analog_bridge md380-emu
```

#### 5️⃣ Verify Status
```bash
systemctl status mmdvm_bridge analog_bridge md380-emu
```
✅ All services should show `active (running)`.

---

## 📂 Directory Structure

After installation, your system will look like this:

```text
/opt/
├── MMDVM_Bridge/
│   ├── MMDVM_Bridge      # Compiled binary
│   └── MMDVM_Bridge.ini  # Configuration (Edit this!)
│
├── Analog_Bridge/
│   ├── Analog_Bridge     # Compiled binary
│   └── Analog_Bridge.ini # Configuration (Edit this!)
│
└── md380-emu/
    ├── md380-emu         # Compiled binary
    └── md380-emu.ini     # Configuration (Edit this!)

/var/log/
├── mmdvm/                # MMDVM_Bridge logs
└── analog/               # Analog_Bridge logs
```

---

## ⚙️ Configuration Guide

### 🔑 Essential Settings for `MMDVM_Bridge.ini`

```ini
[General]
Callsign=YOURCALL       # Your Amateur Radio Callsign
Id=123456701            # Your DMR ID + 2 digits (e.g., 01 for instance 1)
Timeout=180
Duplex=0                # 0 = Hotspot mode, 1 = Repeater mode

[DMR Network]
Enable=1
Address=3101.repeater.net # BrandMeister Master (US)
Port=62031
Local=62032
Password=passw0rd       # Your BrandMeister password
Slot1=1
Slot2=1
```

### 🔌 Essential Settings for `Analog_Bridge.ini`

```ini
[GENERAL]
logLevel=2
exportMetadata=true

[AMBE_AUDIO]
address=127.0.0.1
txPort=31103
rxPort=31100

[USRP]
address=127.0.0.1
txPort=32001
rxPort=32001
```

### 🎙️ Essential Settings for `md380-emu.ini`

```ini
[GENERAL]
logLevel=2

[EMULATOR]
listen=127.0.0.1:2470
```

> 💡 **Tip**: For multiple instances, increment ports by 20 for each new instance (see `MULTI-INSTANCE.md`).

---

## 🛠️ Troubleshooting

### ❌ Service Won't Start
Check logs for specific errors:
```bash
tail -f /var/log/mmdvm/mmdvm_bridge.log
tail -f /var/log/analog/analog_bridge.log
```

### 🔒 Firewall Issues
Ensure these ports are open if connecting externally:
*   **62031-62032**: DMR Network
*   **31100-31103**: MMDVM ↔ Analog Bridge
*   **32001+**: USRP Audio (AllStar)

```bash
sudo ufw allow 62031:62032/udp
sudo ufw allow 31100:31103/udp
sudo ufw allow 32001:32010/udp
```

### 🔄 Rebuild After System Update
If a system update breaks compatibility, simply re-run the script:
```bash
sudo ./install-dvswitch-trixie.sh
```
It will recompile binaries against the new libraries automatically.

---

## 📊 System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **CPU** | 1 Core (ARM/Intel) | 2+ Cores |
| **RAM** | 512 MB | 1 GB+ |
| **Storage** | 1 GB | 4 GB+ (for logs) |
| **Network** | 1 Mbps | 10 Mbps+ |

---

## 🤝 Contributing

Contributions are welcome! Please fork the repository and submit a pull request.

1.  Fork the Repo (`Fork` button on GitHub)
2.  Create a Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

---

## 📜 License

This installation script is distributed under the **MIT License**.  
The DVSwitch components (`MMDVM_Bridge`, `Analog_Bridge`, `md380-emu`) retain their original licenses (primarily **ISC** and **GPL**). See individual repositories for details.

*   [MMDVM_Bridge License](https://github.com/DVSwitch/MMDVM_Bridge/blob/master/LICENSE)
*   [Analog_Bridge License](https://github.com/DVSwitch/Analog_Bridge/blob/master/LICENSE)
*   [md380-emu License](https://github.com/DVSwitch/md380-emu/blob/master/LICENSE)

---

## 🔗 Useful Links

*   [DVSwitch Official Website](http://dvswitch.org)
*   [BrandMeister Network](https://brandmeister.network)
*   [AllStarLink](https://www.allstarlink.org)
*   [DMR ID Lookup](https://www.radioid.net)

---

<div align="center">

**Made with ❤️ for the Amateur Radio Community**  
*Debian Trixie | DVSwitch | Ham Radio*

```text
      73 de YO8AIV
```

</div>

