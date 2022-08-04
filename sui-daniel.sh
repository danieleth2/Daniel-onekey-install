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
    echo "docker install success"
}

install_sui(){
apt install wget unzip pass gnupg2 -y
sudo mkdir -p ~/sui-node/devnet && cd ~/sui-node/devnet
sudo wget -O fullnode-template.yaml https://github.com/MystenLabs/sui/raw/main/crates/sui-config/data/fullnode-template.yaml
sudo wget -O genesis.blob https://github.com/MystenLabs/sui-genesis/raw/main/devnet/genesis.blob
sudo wget -O docker-compose.yaml https://raw.githubusercontent.com/MystenLabs/sui/main/docker/fullnode/docker-compose.yaml
sudo sed -i 's/127.0.0.1:9184/0.0.0.0:9184/' fullnode-template.yaml
sudo sed -i 's/127.0.0.1:9000/0.0.0.0:9000/' fullnode-template.yaml
sudo docker-compose pull
sudo docker-compose up -d
echo "Sui run success"
}

read_sui(){
curl --location --request POST 'http://127.0.0.1:9000/' \
    --header 'Content-Type: application/json' \
    --data-raw '{ "jsonrpc":"2.0", "id":1, "method":"sui_getRecentTransactions", "params":[5] }'
}


echo && echo -e " ${Red_font_prefix}Sui 一键安装脚本${Font_color_suffix} by \033[1;35mDaniel\033[0m
此脚本完全免费开源，由推特用户 ${Green_font_prefix}Daniel_eth2开发${Font_color_suffix}，
欢迎关注，如有收费请勿上当受骗。
 ———————————————————————
 ${Green_font_prefix} 1.安装 docker ${Font_color_suffix}
 ${Green_font_prefix} 2.安装 Sui ${Font_color_suffix}
 ${Green_font_prefix} 3.读取 Sui ${Font_color_suffix}
 ———————————————————————" && echo
read -e -p " 请输入数字 [1-3]:" num
case "$num" in
1)
    install_docker
    ;;
2)
    install_sui
    ;;
3)
    read_sui
    ;;
*)
    echo
    echo -e " ${Error} 请输入正确的数字"
    ;;
esac
