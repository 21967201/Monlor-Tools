#!/bin/ash /etc/rc.common
source "$(uci -q get monlor.tools.path)"/scripts/base.sh 
eval `ucish export qiandao`

START=95
STOP=95
SERVICE_USE_PID=1
SERVICE_WRITE_PID=1
SERVICE_DAEMONIZE=1
EXTRA_COMMANDS=" status backup recover"
EXTRA_HELP="        status  Get $appname status"
SETTING_FILE="/tmp/cookie.txt"
[ -z "$qiandao_time" ] && qiandao_time="8"

generate_cookie_conf() {

        rm -rf $SETTING_FILE
        rm -rf $BIN/cookie.txt
        [ "$qiandao_koolshare" == "1" ] && [ -n "$qiandao_koolshare_setting" ] && echo -e "\"koolshare\"=$qiandao_koolshare_setting" >> $SETTING_FILE
        [ "$qiandao_baidu" == "1" ] && [ -n "$qiandao_baidu_setting" ] && echo -e "\"baidu\"=$qiandao_baidu_setting" >> $SETTING_FILE
        [ "$qiandao_v2ex" == "1" ] && [ -n "$qiandao_v2ex_setting" ] && echo -e "\"v2ex\"=$qiandao_v2ex_setting" >> $SETTING_FILE
        [ "$qiandao_hostloc" == "1" ] && [ -n "$qiandao_hostloc_setting" ] && echo -e "\"hostloc\"=$qiandao_hostloc_setting" >> $SETTING_FILE
        [ "$qiandao_acfun" == "1" ] && [ -n "$qiandao_acfun_setting" ] && echo -e "\"acfun\"=$qiandao_acfun_setting" >> $SETTING_FILE
        [ "$qiandao_bilibili" == "1" ] && [ -n "$qiandao_bilibili_setting" ] && echo -e "\"bilibili\"=$qiandao_bilibili_setting" >> $SETTING_FILE
        [ "$qiandao_smzdm" == "1" ] && [ -n "$qiandao_smzdm_setting" ] && echo -e "\"smzdm\"=$qiandao_smzdm_setting" >> $SETTING_FILE
        [ "$qiandao_xiami" == "1" ] && [ -n "$qiandao_xiami_setting" ] && echo -e "\"xiami\"=$qiandao_xiami_setting" >> $SETTING_FILE
        [ "$qiandao_163music" == "1" ] && [ -n "$qiandao_163music_setting" ] && echo -e "\"163music\"=$qiandao_163music_setting" >> $SETTING_FILE
        [ "$qiandao_miui" == "1" ] && [ -n "$qiandao_miui_setting" ] && echo -e "\"miui\"=$qiandao_miui_setting" >> $SETTING_FILE
        [ "$qiandao_52pojie" == "1" ] && [ -n "$qiandao_52pojie_setting" ] && echo -e "\"52pojie\"=$qiandao_52pojie_setting" >> $SETTING_FILE
        [ "$qiandao_kafan" == "1" ] && [ -n "$qiandao_kafan_setting" ] && echo -e "\"kafan\"=$qiandao_kafan_setting" >> $SETTING_FILE
        [ "$qiandao_right" == "1" ] && [ -n "$qiandao_right_setting" ] && echo -e "\"right\"=$qiandao_right_setting" >> $SETTING_FILE
        [ "$qiandao_mydigit" == "1" ] && [ -n "$qiandao_mydigit_setting" ] && echo -e "\"mydigit\"=$qiandao_mydigit_setting" >> $SETTING_FILE
        if [ -f "$SETTING_FILE" ];then
                ln -sf $SETTING_FILE $BIN/cookie.txt
        else
                logsh "【$service】" "检测到你没有填写任何cookie配置！关闭插件！" 
                uci set monlor.$appname.enable=0
                uci commit monlor
                exit 1
        fi

}

add_cron() {

        logsh "【$service】" "添加签到定时任务，每天$qiandao_time点自动签到..."
        cru a $appname "1 $qiandao_time * * * $monlorpath/apps/$appname/script/$appname.sh restart"

}

del_cron() {

        logsh "【$service】" "删除签到定时任务！"
        cru d $appname

}

start() {

        [ -n "$(pidof $appname)" ] && logsh "【$service】" "$appname已经在运行！" && exit 1
        logsh "【$service】" "正在启动$appname服务... "
        # Scripts Here
        generate_cookie_conf
        add_cron
        # iptables -I INPUT -p tcp --dport $port -m comment --comment "monlor-$appname" -j ACCEPT 
        if [ "$qiandao_action" == '2' ]; then
                i=4
                while(true)
                do
                        echo "-------------------------------"
                        cd $BIN && ./$appname 2>&1 | tee $LOG/$appname.log
                        echo "-------------------------------"
                        if [ -z "$(cat $LOG/$appname.log | grep panic)" ]; then 
                                break 
                        else
                                logsh "【$service】" "出错了，1秒后尝试重新启动..."
                                sleep 1
                        fi
                        let i=$i-1
                        [ "$i" -eq 0 ] && logsh "【$service】" "启动$appname服务失败！" && exit 1
                done
        else
                uci set monlor.$appname.qiandao_action='2'
                uci commit monlor
        fi
        
        logsh "【$service】" "启动$appname服务完成！"
        
}

stop() {

        logsh "【$service】" "正在停止$appname服务... "
        rm -rf $SETTING_FILE
        rm -rf $BIN/cookie.txt
        # service_stop $BIN/$appname
        # kill -9 "$(pidof $appname)"
        # iptables -D INPUT -p tcp --dport $port -m comment --comment "monlor-$appname" -j ACCEPT > /dev/null 2>&1
        [ "$enable" == '0' ] && destroy

}

destroy() {
        
        # End app, Scripts here 
        del_cron
        return

}

restart() {

        stop 
        sleep 1
        start

}

status() {

        if [ -n "$(cru l | grep $appname)" -a -f $BIN/cookie.txt ]; then
                echo -e "运行中，每天$qiandao_time点自动签到\n1"
        else
                echo -e "未运行\n0"
        fi
}

backup() {

        mkdir -p $monlorbackup/$appname
        return

}

recover() {

        return

}
