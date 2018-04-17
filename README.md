# <center>pvex</center>

# <span id="catalog">目录</span>
* [集群管理](#cc)
    - [pvex v5.1](#pvex)
    - [pve v5.1](#pve)
    - [pve v5.1-51](#pve51)


# <span id="cc">集群管理</span>  <font size=4>[目录](#catalog)</font> 
***
## <span id="pvex">pvex v5.1的前后端操作</span>  <font size=3>[目录](#catalog)</font>
基于ProxmoxVE官方发行版的二次开发：

* 集群创建和加入集群的RESTful API
* 前端web的集群管理
* 自动完成所有集群节点的hosts文件更新

源码：<a href="https://git.proxmox.com/?p=pve-manager.git;a=commit;h=0b958203d15db64ecb9609faefe663753aa04ccf" target="_blank">https://git.proxmox.com/?p=pve-manager.git;a=commit;h=0b958203d15db64ecb9609faefe663753aa04ccf</a>

*注意：v5.1的update已经有集群管理的web实现，下一个发行版应该会正式发布。虽然通过pvecm命令来配置集群没有一点障碍，但还是一直觉得pve的集群管理没有web实现挺美中稍微不足。*

利用了几天下班时间，完善了之前几个版本的实现，由于pve马上会有官方实现，该feature作为一次总结学习吧


### pvesh   

    1） 创建集群    
```# pvesh set cluster/cc/create --clustername pvex```

![](https://github.com/leonlm/pvex/blob/master/doc/images/node2_cc_create.png?raw=true)

    2） 加入集群     
```# pvesh set /cluster/cc/add --address 192.168.247.232 --hostname node2 --password 123456```

![](https://github.com/leonlm/pvex/blob/master/doc/images/node2_hosts.png?raw=true)


### WEB

    1) 集群管理

![](https://github.com/leonlm/pvex/blob/master/doc/images/pvex_ClusterConfig.png?raw=true)

    2) 创建集群

![](https://github.com/leonlm/pvex/blob/master/doc/images/pvex_create.png?raw=true)


    3) 加入集群

![](https://github.com/leonlm/pvex/blob/master/doc/images/pvex_add.png?raw=true)


## <span id="pve">pve v5.1的后端操作</span>  <font size=3>[目录](#catalog)</font>
- proxmox-ve_5.1-3.iso发行版的集群管理还未实现web管理
- v5.1-51的update中已经实现了web来管理集群

### pvecm
    1) 集群创建
```node1# pvecm create pvex```

    2) 加入集群
```node2# pvecm add node1```

## <span id="pve51">pve v5.1-51的前端操作</span>  <font size=3>[目录](#catalog)</font>

### web

    1) Cluster
![](https://github.com/leonlm/pvex/blob/master/doc/images/pve_ClusterConfig.png?raw=true)


    2) 创建集群

![](https://github.com/leonlm/pvex/blob/master/doc/images/pve_create.png?raw=true)

![](https://github.com/leonlm/pvex/blob/master/doc/images/pve_create1.png?raw=true)

    3) 查看Join Information

![](https://github.com/leonlm/pvex/blob/master/doc/images/pve_join_information.png?raw=true)


    4) 加入集群

![](https://github.com/leonlm/pvex/blob/master/doc/images/pve_add.png?raw=true)

    5) 后端信息

```# pvecm status```

![](https://github.com/leonlm/pvex/blob/master/doc/images/pve_pvecm.png?raw=true)

```# cat /etc/hosts```

![](https://github.com/leonlm/pvex/blob/master/doc/images/pve_hosts.png?raw=true)






