Crontab_file="/usr/bin/crontab"
Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Green_background_prefix="\033[42;37m"
Red_background_prefix="\033[41;37m"
Font_color_suffix="\033[0m"
Info="[${Green_font_prefix}信息${Font_color_suffix}]"
Error="[${Red_font_prefix}错误${Font_color_suffix}]"
Tip="[${Green_font_prefix}注意${Font_color_suffix}]"
check_root() {
    [[ $EUID != 0 ]] && echo -e "${Error} 当前非ROOT账号(或没有ROOT权限)，无法继续操作，请更换ROOT账号或使用 ${Green_background_prefix}sudo su${Font_color_suffix} 命令获取临时ROOT权限（执行后可能会提示输入当前账号的密码）。" && exit 1
}

install_docker(){
    check_root
    curl -fsSL https://get.docker.com | bash -s docker
    sudo systemctl daemon-reload
    sudo systemctl restart docker
    curl -L https://get.daocloud.io/docker/compose/releases/download/v2.5.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    docker-compose --version
}

install_aptos(){
read -p " 请输入服务器外网ip地址:" ip
echo $ip
read -p " 请输入节点名字（自定义）:" name
echo $name
##install aptos
wget https://github.com/aptos-labs/aptos-core/releases/download/aptos-cli-0.2.0/aptos-cli-0.2.0-Ubuntu-x86_64.zip
unzip aptos-cli-0.2.0-Ubuntu-x86_64.zip 
cp aptos /usr/local/bin
chmod 777 /usr/local/bin/aptos

## install config
echo export WORKSPACE=testnet >> /etc/profile
source /etc/profile
mkdir ~/$WORKSPACE
cd ~/$WORKSPACE
wget https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/aptos-node/docker-compose.yaml
wget https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/aptos-node/validator.yaml
aptos genesis generate-keys --output-dir ~/$WORKSPACE


aptos genesis set-validator-configuration \
    --keys-dir ~/$WORKSPACE --local-repository-dir ~/$WORKSPACE \
    --username $name \
    --validator-host $ip:6180 \
    --full-node-host $ip:6182


cat > layout.yaml << EOF
---
root_key: "F22409A93D1CD12D2FC92B5F8EB84CDCD24C348E32B3E7A720F3D2E288E63394"
users:
  - "$name"
chain_id: 40
min_stake: 0
max_stake: 100000
min_lockup_duration_secs: 0
max_lockup_duration_secs: 2592000
epoch_duration_secs: 86400
initial_lockup_timestamp: 1656615600
min_price_per_gas_unit: 1
allow_new_validators: true
EOF

wget https://github.com/aptos-labs/aptos-core/releases/download/aptos-framework-v0.2.0/framework.zip
unzip framework.zip
aptos genesis generate-genesis --local-repository-dir ~/$WORKSPACE --output-dir ~/$WORKSPACE
sudo docker-compose up -d
echo "启动成功"

}

read_aptos(){
    source /etc/profile
    read -p " 请输入节点名字:" name
    cat ~/$WORKSPACE/$name.yaml
}


echo && echo -e " ${Red_font_prefix}Aptos 一键安装脚本${Font_color_suffix} by \033[1;35mDaniel\033[0m
此脚本完全免费开源，由推特用户 ${Green_font_prefix}Daniel_eth2开发${Font_color_suffix}，
欢迎关注，如有收费请勿上当受骗。
 ———————————————————————
 ${Green_font_prefix} 1.安装 docker ${Font_color_suffix}
 ${Green_font_prefix} 2.安装 Aptos ${Font_color_suffix}
 ${Green_font_prefix} 3.读取 Aptos信息 ${Font_color_suffix}
 ———————————————————————" && echo
read -e -p " 请输入数字 [1-3]:" num
case "$num" in
1)
    install_docker
    ;;
2)
    install_aptos
    ;;
3)
    read_aptos
    ;;
*)
    echo
    echo -e " ${Error} 请输入正确的数字"
    ;;
esac
