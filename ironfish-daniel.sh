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
    echo "docker 安装完成"
}

install_ironfish(){
    read -p " 请输入节点名字（跟官方注册的一样）:" name
    echo "你输入的节点名字是 $name"
    read -r -p "请确认输入的节点名字正确，正确请输入Y，否则将退出 [Y/n] " input
    case $input in
        [yY][eE][sS]|[yY])
            echo "继续安装"
            ;;

        *)
            echo "退出安装..."
            exit 1
            ;;
    esac
    docker pull ghcr.io/iron-fish/ironfish:latest
    docker run -itd --name node --net host --volume /root/.node:/root/.ironfish ghcr.io/iron-fish/ironfish:latest start
    sleep 10
    docker exec -it node bash -c "ironfish config:set blockGraffiti ${name}"
    docker exec -it node bash -c "ironfish config:set enableTelemetry true"
    echo "启动成功！"
}

read_ironfish(){
    echo "请检查状态"
    docker exec -it node bash -c "ironfish config:show" | grep blockGraffiti 
    docker exec -it node bash -c "ironfish config:show" | grep enableTelemetry
    docker exec -it node bash -c "ironfish status"
}


echo && echo -e " ${Red_font_prefix}IronFish 一键安装脚本${Font_color_suffix} by \033[1;35mDaniel\033[0m
此脚本完全免费开源，由推特用户 ${Green_font_prefix}Daniel_eth2开发${Font_color_suffix}，
欢迎关注，如有收费请勿上当受骗。
 ———————————————————————
 ${Green_font_prefix} 1.安装 docker ${Font_color_suffix}
 ${Green_font_prefix} 2.安装 Ironfish ${Font_color_suffix}
 ${Green_font_prefix} 3.检查 Ironfish状态 ${Font_color_suffix}
 ———————————————————————" && echo
read -e -p " 请输入数字 [1-3]:" num
case "$num" in
1)
    install_docker
    ;;
2)
    install_ironfish
    ;;
3)
    read_ironfish
    ;;
*)
    echo
    echo -e " ${Error} 请输入正确的数字"
    ;;
esac