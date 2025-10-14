#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/marfnl/ProxmoxVED/tree/Bus-Factor-Explorer/misc/build.func)
# Copyright (c) 2021-2025 community-scripts ORG
# Author: Marfnl
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/jetbrains-research/bus-factor-explorer/

APP="Bus-Factor-Explorer"
var_tags="${var_tags:-monitoring}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-4096}"
var_disk="${var_disk:-40}"
var_os="${var_os:-debian}"
var_version="${var_version:-12}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources
  if [[ ! -d /opt/bus-factor-explorer ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  if check_for_gh_release "bus-factor-explorer" "jetbrains-research/bus-factor-explorer/"; then
    msg_info "Stopping $APP"
    systemctl stop bus-factor-explorer
    msg_ok "Stopped $APP"

    msg_info "Creating backup"
    mv /opt/bus-factor-explorer/bus-factor.yml /opt
    msg_ok "Backup created"

    fetch_and_deploy_gh_release "bus-factor-explorer" "jetbrains-research/bus-factor-explorer/" "prebuild" "latest" "/opt/bus-factor-explorer" "bus-factor-explorer-*.linux-amd64.tar.gz"

    msg_info "Restoring backup"
    cp -r /opt/bus-factor.yml /opt/bus-factor-explorer
    rm -f /opt/bus-factor.yml
    msg_ok "Backup restored"
    
    msg_info "Starting $APP"
    systemctl start bus-factor-explorer
    msg_ok "Started $APP"
    msg_ok "Update Successful"
  fi
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:9115${CL}"
