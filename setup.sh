#!/bin/sh
reset='\033[0m'
BGreen='\033[1;32m'       # Green

echo ""
echo -e "${BGreen}Start Shell Script with bash${reset}"
sudo bash

echo ""
echo -e "${BGreen}test ping 8.8.8.8${reset}"
ping -c 4 8.8.8.8

echo ""
echo -e "${BGreen}get into /root/${reset}"
cd /root/

echo ""
echo -e "${BGreen}Cheking the Update 1${reset}"
apt-get update

echo ""
echo -e "${BGreen}Cheking the Update 2${reset}"
apt-get update --allow-releaseinfo-change

echo ""
echo -e "${BGreen}Upgrade if Any${reset}"
apt-get upgrade -y

echo ""
echo -e "${BGreen}Cleanup${reset}"
apt autoremove
apt clean

echo ""
echo -e "${BGreen}install vnc${reset}"
apt-get install realvnc-vnc-server realvnc-vnc-viewer
echo "Done"

echo ""
echo -e "${BGreen}turn on VNC interfaces${reset}"
raspi-config
echo "Interfacing Options>P2 VNC>Yes>Ok>Finish"

echo ""
echo -e "${BGreen}installing Prometheus${reset}"
wget https://github.com/prometheus/prometheus/releases/download/v2.21.0/prometheus-2.21.0.linux-armv7.tar.gz
tar -zxvf prometheus-*.tar.gz
rm prometheus-*.tar.gz
mv prometheus-* prometheus

echo ""
echo -e "${BGreen}Created prometheus.service${reset}"
printf '%s\n' '[Unit]' 'Description=Prometheus Server' 'Documentation=https://prometheus.io/docs/introduction/overview/' 'After=network-online.target' '' '[Service]' 'User=root' 'Restart=on-failure' '' 'ExecStart=/root/prometheus/prometheus \' '  --config.file=/root/prometheus/prometheus.yml \' '  --storage.tsdb.path=/root/prometheus/data' '' '[Install]' 'WantedBy=multi-user.target' >> /etc/systemd/system/prometheus.service
echo "Done"

echo ""
echo -e "${BGreen}Start and enable Prometheus Services${reset}"
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
echo "Done"

echo ""
echo -e "${BGreen}installing node_exporter${reset}"
wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-armv7.tar.gz
tar -zxvf node_exporter-*.tar.gz
rm node_exporter-*.tar.gz
mv node_exporter-* node_exporter

echo ""
echo -e "${BGreen}Created node_exporter.service${reset}"
printf '%s\n' '[Unit]' 'Description=Node Exporter' 'Wants=network-online.target' 'After=network-online.target' '' '[Service]' 'User=root' 'ExecStart=/root/node_exporter/node_exporter' '' '[Install]' 'WantedBy=default.target' >> /etc/systemd/system/node_exporter.service
echo "Done"

echo ""
echo -e "${BGreen}Start and enable node_exporter Services${reset}"
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
echo "Done"

echo ""
echo -e "${BGreen}add node_exporter to prometheus.yml${reset}"
printf "%s\n" "   - targets: ['localhost:9100']" >> /root/prometheus/prometheus.yml
echo "Done"

echo ""
echo -e "${BGreen}Restart Prometheus${reset}"
echo "Done"

echo ""
echo -e "${BGreen}Installing Grafana${reset}"
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
apt-get update
apt-get install -y grafana

echo ""
echo -e "${BGreen}Start and enable Grafana Services${reset}"
sudo /bin/systemctl enable grafana-server
sudo /bin/systemctl start grafana-server
echo "Done"

echo ""
echo -e "${BGreen}install pihole${reset}"
curl -sSL https://install.pi-hole.net | bash

echo ""
echo -e "${BGreen}Done${reset}"

echo ""
echo -e "${BGreen}Reboot${reset}"
reboot
