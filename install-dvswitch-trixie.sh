#!/bin/bash
#################################################################
# DVSwitch Server Installer for Debian 13 (Trixie)
# Compiles MMDVM_Bridge, Analog_Bridge, and md380-emu from source
# Creates systemd services and directory structure
# Author: Generated for DVSwitch Community
# Date: June 2026
#################################################################

set -e # Exit on error

echo ">>> Starting DVSwitch Installation for Debian Trixie..."

# 1. Install Build Dependencies
echo ">>> Installing build dependencies..."
apt-get update
apt-get install -y git build-essential libssl-dev libcurl4-openssl-dev \
    libopus-dev libasound2-dev nodejs npm php-cli php-cgi lighttpd \
    spawn-fcgi libjsoncpp-dev libctemplate-dev systemd

# 2. Create Directory Structure
echo ">>> Creating directory structure..."
mkdir -p /opt/MMDVM_Bridge /opt/Analog_Bridge /opt/md380-emu
mkdir -p /var/log/mmdvm /var/log/analog

# 3. Compile MMDVM_Bridge
echo ">>> Compiling MMDVM_Bridge..."
cd /tmp
rm -rf MMDVM_Bridge
git clone https://github.com/DVSwitch/MMDVM_Bridge.git
cd MMDVM_Bridge/src
make clean
make
cp MMDVM_Bridge /opt/MMDVM_Bridge/
cp ../MMDVM_Bridge.ini /opt/MMDVM_Bridge/

# 4. Compile Analog_Bridge
echo ">>> Compiling Analog_Bridge..."
cd /tmp
rm -rf Analog_Bridge
git clone https://github.com/DVSwitch/Analog_Bridge.git
cd Analog_Bridge
make clean
make
cp Analog_Bridge /opt/Analog_Bridge/
cp Analog_Bridge.ini /opt/Analog_Bridge/

# 5. Compile md380-emu
echo ">>> Compiling md380-emu..."
cd /tmp
rm -rf md380-emu
git clone https://github.com/DVSwitch/md380-emu.git
cd md380-emu
make clean
make
cp md380-emu /opt/md380-emu/
cp md380-emu.ini /opt/md380-emu/

# 6. Create Systemd Service Files
echo ">>> Creating systemd services..."

cat > /etc/systemd/system/mmdvm_bridge.service <<EOF
[Unit]
Description=MMDVM Bridge
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/MMDVM_Bridge
ExecStart=/opt/MMDVM_Bridge/MMDVM_Bridge MMDVM_Bridge.ini
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/analog_bridge.service <<EOF
[Unit]
Description=Analog Bridge
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/Analog_Bridge
ExecStart=/opt/Analog_Bridge/Analog_Bridge Analog_Bridge.ini
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/md380-emu.service <<EOF
[Unit]
Description=MD380 Emulator
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/md380-emu
ExecStart=/opt/md380-emu/md380-emu md380-emu.ini
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

# 7. Enable and Start Services
echo ">>> Enabling and starting services..."
systemctl daemon-reload
systemctl enable mmdvm_bridge analog_bridge md380-emu
systemctl start mmdvm_bridge analog_bridge md380-emu

# 8. Final Instructions
echo ""
echo ">>> Installation Complete!"
echo ">>> Configuration files are located in:"
echo "    /opt/MMDVM_Bridge/MMDVM_Bridge.ini"
echo "    /opt/Analog_Bridge/Analog_Bridge.ini"  
echo "    /opt/md380-emu/md380-emu.ini"
echo ""
echo ">>> Edit these files to set your DMR ID, Callsign, and Master Server."
echo ">>> Then restart services: systemctl restart mmdvm_bridge analog_bridge md380-emu"
echo ""
echo ">>> Check status: systemctl status mmdvm_bridge analog_bridge md380-emu"   
