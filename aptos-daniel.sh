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
    ##安装docker
    # curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
    curl -fsSL https://get.docker.com | bash -s docker
    # ##docker换源
    # sudo mkdir -p /etc/docker
    # echo -e "{ 
    #     \"registry-mirrors\": [\"https://hub-mirror.c.163.com\"]
    # } 
    # " > /etc/docker/daemon.json

    sudo systemctl daemon-reload
    sudo systemctl restart docker

    ##安装docker-ce
    curl -L https://get.daocloud.io/docker/compose/releases/download/v2.5.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    docker-compose --version
}

install_aptos(){
    read -p " 请输入服务器外网ip地址:" ip
    echo $ip
    read -p " 请输入节点名字（自定义）:" name
    echo $name
    sudo mkdir -p ~/aptos-node/testnet && cd ~/aptos-node/testnet

    sudo docker run --rm \
    -v $(pwd):/data/aptos-cli \
    jiangydev/aptos-cli:v0.1.1 \
    aptos genesis generate-keys --output-dir /data/aptos-cli

    sudo wget -O docker-compose.yaml https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/aptos-node/docker-compose.yaml
    sudo wget -O validator.yaml https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/aptos-node/validator.yaml
    sudo wget -O fullnode.yaml https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/aptos-node/fullnode.yaml

    sudo docker run --rm \
    -v $(pwd):/data/aptos-cli \
    jiangydev/aptos-cli:v0.1.1 \
    aptos genesis set-validator-configuration \
    --keys-dir /data/aptos-cli --local-repository-dir /data/aptos-cli \
    --username $name \
    --validator-host $ip:6180 \
    --full-node-host $ip:6182

    echo -e "
    root_key: "0x5243ca72b0766d9e9cbf2debf6153443b01a1e0e6d086c7ea206eaf6f8043956" \n
    users: \n
    - $name \n
    chain_id: 23 \n
    " > layout.yaml

    sudo docker run --rm \
    -v $(pwd):/data/aptos-cli \
    jiangydev/aptos-cli:v0.1.1 \
    sh -c "rm -rf /data/aptos-cli/genesis.blob && rm -rf /data/aptos-cli/waypoint.txt && rm -rf /data/aptos-cli/framework && cp -r /framework /data/aptos-cli && aptos genesis generate-genesis --local-repository-dir /data/aptos-cli --output-dir /data/aptos-cli && rm -rf /data/aptos-cli/framework"

    sudo docker-compose up -d

    cp $name.yaml ~root/

}

read_aptos(){
    read -p " 请输入节点名字:" name
    cat $name.yaml
}


echo && echo -e " ${Red_font_prefix}Aptos 一键安装脚本${Font_color_suffix} by \033[1;35mDaniel\033[0m
此脚本完全免费开源，由推特用户 ${Green_font_prefix}Daniel_eth2开发${Font_color_suffix}，
欢迎关注，如有收费请勿上当受骗。
 ———————————————————————
 ${Green_font_prefix} 1.安装 docker ${Font_color_suffix}
 ${Green_font_prefix} 2.安装 Aptos ${Font_color_suffix}
 ${Green_font_prefix} 3.读取 Aptos信息 ${Font_color_suffix}
 ———————————————————————" && echo
read -e -p " 请输入数字 [1-2]:" num
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