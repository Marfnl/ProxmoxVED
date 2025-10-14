#!/usr/bin/env bash

# Copyright (c) 2021-2025 community-scripts ORG
# Author: Marfnl
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/jetbrains-research/bus-factor-explorer/

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

fetch_and_deploy_gh_release "bus-factor-explorer" "jetbrains-research/bus-factor-explorer" "prebuild" "latest" "/opt/bus-factor-explorer" "bus-factor-explorer-*.linux-amd64.tar.gz"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/bus-factor-explorer.service
[Unit]
Description=Bus Factor Explorer
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/bus-factor-explorer
ExecStart=/opt/bus-factor-explorer/bus-factor-explorer
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now bus-factor-explorer
msg_ok "Service Created"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
