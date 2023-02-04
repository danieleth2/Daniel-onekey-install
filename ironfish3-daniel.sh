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
    curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install gcc g++ make -y
    sudo apt-get install -y nodejs
    npm install -g npm@9.4.1
    npm install -g ironfish
    echo "安装成功！"
    nohup ironfish start > ironfish.test.log 2>&1 &
    ironfish config:set blockGraffiti $name
    ironfish config:set enableTelemetry true
    echo "启动成功！"
}

read_ironfish(){
    echo "请检查状态"
    ironfish config | grep blockGraffiti 
    ironfish config | grep enableTelemetry
    ironfish status
}

echo && echo -e " ${Red_font_prefix}IronFish 一键安装脚本${Font_color_suffix} by \033[1;35mDaniel\033[0m
此脚本完全免费开源，由推特用户 ${Green_font_prefix}Daniel_eth2开发${Font_color_suffix}，
欢迎关注，如有收费请勿上当受骗。
 ———————————————————————
 ${Green_font_prefix} 1.安装 Ironfish ${Font_color_suffix}
 ${Green_font_prefix} 2.检查 Ironfish状态 ${Font_color_suffix}
 ———————————————————————" && echo
read -e -p " 请输入数字 [1-2]:" num
case "$num" in
1)
    install_ironfish
    ;;
2)
    read_ironfish
    ;;
*)
    echo
    echo -e " ${Error} 请输入正确的数字"
    ;;
esac
