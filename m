Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6ECEB6B0387
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 07:58:32 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id c80so23105544iod.4
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 04:58:32 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id t69si17769753iof.241.2017.02.09.04.58.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Feb 2017 04:58:31 -0800 (PST)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [RFC] 3.10 kernel- oom with about 24G free memory
Message-ID: <9a22aefd-dfb8-2e4c-d280-fc172893bcb4@huawei.com>
Date: Thu, 9 Feb 2017 20:54:49 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hanjun Guo <guohanjun@huawei.com>

Hi all,
I get an oom on a linux 3.10 kvm guest OS. when it triggers the oom
it have about 24G free memory(and host OS have about 10G free memory)
and watermark is sure ok.

I also check about about memcg limit value, also cannot find the
root cause.

Is there anybody ever meet similar problem and have any idea about it?

Any comment is more than welcome!

Thanks
Yisheng Xie

-------------
[   81.234289] DefSch0200 invoked oom-killer: gfp_mask=0xd0, order=0, oom_score_adj=0
[   81.234295] DefSch0200 cpuset=/ mems_allowed=0
[   81.234299] CPU: 3 PID: 8284 Comm: DefSch0200 Tainted: G           O E ----V-------   3.10.0-229.42.1.105.x86_64 #1
[   81.234301] Hardware name: OpenStack Foundation OpenStack Nova, BIOS rel-1.8.1-0-g4adadbd-20161111_105425-HGH1000008200 04/01/2014
[   81.234303]  ffff880ae2900000 000000002b3489d7 ffff880b6cec7c58 ffffffff81608d3d
[   81.234307]  ffff880b6cec7ce8 ffffffff81603d1c 0000000000000000 ffff880b6cd09000
[   81.234311]  ffff880b6cec7cd8 000000002b3489d7 ffff880b6cec7ce0 ffffffff811bdd77
[   81.234314] Call Trace:
[   81.234323]  [<ffffffff81608d3d>] dump_stack+0x19/0x1b
[   81.234327]  [<ffffffff81603d1c>] dump_header+0x8e/0x214
[   81.234333]  [<ffffffff811bdd77>] ? mem_cgroup_iter+0x177/0x2b0
[   81.234339]  [<ffffffff8115d83e>] check_panic_on_oom+0x2e/0x60
[   81.234342]  [<ffffffff811c17bf>] mem_cgroup_oom_synchronize+0x34f/0x580
[   81.234346]  [<ffffffff811c0db0>] ? mem_cgroup_charge_common+0xc0/0xc0
[   81.234350]  [<ffffffff8115df44>] pagefault_out_of_memory+0x14/0x90
[   81.234353]  [<ffffffff81602104>] mm_fault_error+0x8e/0x180
[   81.234358]  [<ffffffff8161492b>] __do_page_fault+0x44b/0x560
[   81.234363]  [<ffffffff810b34bc>] ? update_curr+0xcc/0x150
[   81.234368]  [<ffffffff8101260b>] ? __switch_to+0x17b/0x4d0
[   81.234372]  [<ffffffff81614af3>] trace_do_page_fault+0x43/0x100
[   81.234375]  [<ffffffff816140e9>] do_async_page_fault+0x29/0xe0
[   81.234379]  [<ffffffff81610b78>] async_page_fault+0x28/0x30
[   81.234381] Mem-Info:
[   81.234382] Node 0 DMA per-cpu:
[   81.234385] CPU    0: hi:    0, btch:   1 usd:   0
[   81.234387] CPU    1: hi:    0, btch:   1 usd:   0
[   81.234389] CPU    2: hi:    0, btch:   1 usd:   0
[   81.234390] CPU    3: hi:    0, btch:   1 usd:   0
[   81.234392] Node 0 DMA32 per-cpu:
[   81.234394] CPU    0: hi:  186, btch:  31 usd: 181
[   81.234396] CPU    1: hi:  186, btch:  31 usd:  43
[   81.234398] CPU    2: hi:  186, btch:  31 usd: 167
[   81.234400] CPU    3: hi:  186, btch:  31 usd:  46
[   81.234401] Node 0 Normal per-cpu:
[   81.234404] CPU    0: hi:  186, btch:  31 usd:  79
[   81.234405] CPU    1: hi:  186, btch:  31 usd:  98
[   81.234407] CPU    2: hi:  186, btch:  31 usd: 171
[   81.234409] CPU    3: hi:  186, btch:  31 usd: 129
[   81.234414] active_anon:4453349 inactive_anon:175045 isolated_anon:0
 active_file:117415 inactive_file:180454 isolated_file:128
 unevictable:0 dirty:24 writeback:0 unstable:0
 free:6464114 slab_reclaimable:20430 slab_unreclaimable:9134
 mapped:128290 shmem:458882 pagetables:11540 bounce:0
 free_cma:0
[   81.234419] Node 0 DMA free:15900kB min:20kB low:24kB high:28kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15992kB managed:15908kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:8kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[   81.234425] lowmem_reserve[]: 0 2720 47985 47985
[   81.234428] Node 0 DMA32 free:432780kB min:3832kB low:4788kB high:5748kB active_anon:1935160kB inactive_anon:41196kB active_file:29556kB inactive_file:43800kB unevictable:0kB isolated(anon):0kB isolated(file):256kB present:3129212kB managed:2787816kB mlocked:0kB dirty:40kB writeback:0kB mapped:31292kB shmem:115068kB slab_reclaimable:5100kB slab_unreclaimable:2452kB kernel_stack:48kB pagetables:4368kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[   81.234434] lowmem_reserve[]: 0 0 45264 45264
[   81.234437] Node 0 Normal free:25407776kB min:63728kB low:79660kB high:95592kB active_anon:15878236kB inactive_anon:658984kB active_file:440104kB inactive_file:678016kB unevictable:0kB isolated(anon):0kB isolated(file):256kB present:47138816kB managed:46350696kB mlocked:0kB dirty:56kB writeback:0kB mapped:481868kB shmem:1720460kB slab_reclaimable:76620kB slab_unreclaimable:34076kB kernel_stack:9568kB pagetables:41792kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[   81.234443] lowmem_reserve[]: 0 0 0 0
[   81.234447] Node 0 DMA: 1*4kB (U) 1*8kB (U) 1*16kB (U) 0*32kB 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M) = 15900kB
[   81.234461] Node 0 DMA32: 12*4kB (UEM) 5*8kB (EM) 1*16kB (M) 9*32kB (UEM) 3*64kB (UM) 1*128kB (U) 2*256kB (UM) 3*512kB (UEM) 0*1024kB 2*2048kB (UE) 104*4096kB (MR) = 432840kB
[   81.234476] Node 0 Normal: 431*4kB (UEM) 220*8kB (UEM) 233*16kB (UEM) 179*32kB (UEM) 60*64kB (UM) 14*128kB (UEM) 1*256kB (E) 4*512kB (UM) 2*1024kB (UE) 3*2048kB (UEM) 6196*4096kB (MR) = 25407884kB
[   81.234492] Node 0 hugepages_total=1024 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[   81.234493] 757867 total pagecache pages
[   81.234495] 0 pages in swap cache
[   81.234497] Swap cache stats: add 0, delete 0, find 0/0
[   81.234499] Free swap  = 0kB
[   81.234500] Total swap = 0kB
[   81.234502] 12571005 pages RAM
[   81.234503] 0 pages HighMem/MovableOnly
[   81.234504] 282400 pages reserved
[   81.234506] [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
[   81.234516] [  385]     0   385    13023      894      25        0             0 systemd-journal
[   81.234520] [  388]     0   388    13867      293      21        0             0 lvmetad
[   81.234523] [  391]     0   391    10467      443      22        0         -1000 systemd-udevd
[   81.234526] [  464]     0   464    12797      403      23        0         -1000 auditd
[   81.234536] [  608]     0   608     4822      306      13        0             0 irqbalance
[   81.234539] [  632]     0   632    36663      983      33        0             0 rsyslogd
[   81.234542] [  634]     0   634     6619      531      18        0             0 smartd
[   81.234545] [  642]     0   642    62585     4067      81        0             0 tuned
[   81.234548] [  652]     0   652     2910      387      10        0             0 getosstat
[   81.234552] [  653]     0   653     8148      383      21        0             0 systemd-logind
[   81.234555] [  655]    81   655     6615      364      18        0          -900 dbus-daemon
[   81.234558] [  666]    32   666    11024      315      25        0             0 rpcbind
[   81.234561] [  684]     0   684     1630       84       8        0             0 mcelog
[   81.234565] [  698]     0   698     5696      387      17        0             0 crond
[   81.234568] [  717]     0   717    24939      291      38        0             0 gssproxy
[   81.234571] [  719]     0   719     2975      458      10        0             0 bash
[   81.234574] [  737]     0   737    27316      238      21        0             0 sysmonitor
[   81.234577] [  766]     0   766    10024      139      23        0             0 rpc.gssd
[   81.234581] [  809]     0   809     1079       90       8        0             0 sleep
[   81.234585] [ 1009]     0  1009     2944      424      11        0             0 bash
[   81.234588] [ 1017]     0  1017     6246      164      11        0             0 ip_conflict_che
[   81.234591] [ 1024]    29  1024    11131      429      25        0             0 rpc.statd
[   81.234594] [ 1033]     0  1033     3182      139      11        0             0 ip_conflict_che
[   81.234597] [ 1077]     0  1077     2942      263       9        0             0 sh
[   81.234600] [ 1118]     0  1118      497       65       4        0             0 vm-agent
[   81.234604] [ 1121]     0  1121    33300      290      14        0             0 vm-agent
[   81.234607] [ 1294]     0  1294     2942      379      11        0             0 sh
[   81.234610] [ 4104]     0  4104    16630      821      34        0         -1000 sshd
[   81.234613] [ 4108]     0  4108     1614      195       9        0             0 agetty
[   81.234616] [ 4114]     0  4114    27509      206       9        0             0 agetty
[   81.234619] [ 6925]     0  6925    22479      956      33        0             0 ministarter
[   81.234622] [ 6971]     0  6971    18944      531      22        0             0 dsle_boot
[   81.234626] [10789]     0 10789    16857      941      31        0             0 monitor
[   81.234630] [10805]     0 10805    98894    10124     106        0             0 monitor
[   81.234633] [10818]     0 10818     2911      393      11        0             0 fenixlog.sh
[   81.234636] [10823]     0 10823     2976      452      10        0             0 log_monitor.sh
[   81.234639] [19370]     0 19370    13195      645      31        0             0 vsftpd
[   81.234643] [21904]     0 21904   854601   124104     368        0             0 monitor
[   81.234646] [23075]     0 23075    20430      885      34        0             0 ministarter
[   81.234650] [24088]     0 24088    20430      892      35        0             0 ministarter
[   81.234653] [24098]     0 24098    18943      532      23        0             0 dsle_boot
[   81.234656] [24749]     0 24749     3010      499      12        0             0 start_nls_agent
[   81.234659] [24871]     0 24871    20430      892      34        0             0 ministarter
[   81.234662] [24901]     0 24901    18943      532      24        0             0 dsle_boot
[   81.234666] [25540]     0 25540     3010      499      12        0             0 start_nls_agent
[   81.234669] [26600]     0 26600    20430      893      33        0             0 ministarter
[   81.234672] [26617]     0 26617    18943      532      23        0             0 dsle_boot
[   81.234675] [26670]     0 26670    16857      943      30        0             0 monitor
[   81.234678] [26686]     0 26686    38863     4122      45        0             0 monitor
[   81.234681] [26687]     0 26687    14281      926      31        0             0 monitor
[   81.234684] [26698]     0 26698     2911      392      11        0             0 fenixlog.sh
[   81.234687] [26705]     0 26705     2943      427      10        0             0 log_monitor.sh
[   81.234691] [26989]     0 26989     3010      499      10        0             0 start_nls_agent
[   81.234694] [28511]     0 28511    16857      946      32        0             0 monitor
[   81.234697] [28534]     0 28534    84711     9133     120        0             0 monitor
[   81.234700] [28620]     0 28620     2911      393      12        0             0 fenixlog.sh
[   81.234703] [28626]     0 28626     2943      426      11        0             0 log_monitor.sh
[   81.234706] [28706]     0 28706    16857      941      30        0             0 monitor
[   81.234709] [28725]     0 28725    38863     4516      44        0             0 monitor
[   81.234712] [28726]     0 28726    14281      928      31        0             0 monitor
[   81.234715] [28834]     0 28834     2911      393      11        0             0 fenixlog.sh
[   81.234718] [28843]     0 28843     2943      426      11        0             0 log_monitor.sh
[   81.234721] [29195]     0 29195    20430      891      32        0             0 ministarter
[   81.234724] [29224]     0 29224    18943      532      23        0             0 dsle_boot
[   81.234727] [29719]     0 29719     3010      498      11        0             0 start_nls_agent
[   81.234730] [31928]     0 31928    16857      943      30        0             0 monitor
[   81.234733] [31956]     0 31956    22622     4093      43        0             0 monitor
[   81.234736] [31958]     0 31958    14281      927      31        0             0 monitor
[   81.234739] [32043]     0 32043     2911      392      11        0             0 fenixlog.sh
[   81.234743] [32055]     0 32055     2943      427      11        0             0 log_monitor.sh
[   81.234746] [ 1737]     0  1737     3010      492      11        0             0 start_nls_agent
[   81.234748] [ 4390]     0  4390    13195      644      29        0             0 vsftpd
[   81.234752] [ 4727]  2008  4727    60264     7302      84        0             0 SMU
[   81.234755] [ 5161]  2008  5161    72268     6275      78        0             0 monitor
[   81.234758] [ 5630]  2008  5630    61130    13721      87        0             0 monitor
[   81.234761] [ 6052]  2008  6052  1581697   466583    1079        0             0 SMU
[   81.234764] [ 6205]     0  6205    16857      941      32        0             0 monitor
[   81.234767] [ 6269]     0  6269    38944     4220      42        0             0 monitor
[   81.234771] [ 6270]     0  6270    14281      927      30        0             0 monitor
[   81.234774] [ 6331]  2008  6331  3657668  2629890    5305        0             0 SMU
[   81.234777] [ 6336]     0  6336     2911      392      10        0             0 fenixlog.sh
[   81.234780] [ 6347]     0  6347     2943      427      11        0             0 log_monitor.sh
[   81.234783] [ 6647]     0  6647   233965   110159     350        0             0 SMU
[   81.234786] [ 6935]  2008  6935  1833867   818611    1762        0             0 SMU
[   81.234789] [ 7232]  2008  7232  1077000   100956     358        0             0 SMU
[   81.234792] [14829]     0 14829     1079       90       7        0             0 sleep
[   81.234795] [15071]     0 15071     1079       90       6        0             0 sleep
[   81.234798] [15212]     0 15212     1079       90       8        0             0 sleep
[   81.234801] [15591]     0 15591     1079       90       8        0             0 sleep
[   81.234804] [17403]     0 17403     1079       91       8        0             0 sleep
[   81.234807] [18359]     0 18359     1079       90       7        0             0 sleep
[   81.234810] [18400]     0 18400     2909      373      11        0             0 ip_conflict_che
[   81.234813] [18702]     0 18702     1079       91       8        0             0 sleep
[   81.234816] [18741]     0 18741     2676      174       9        0             0 arping
[   81.234819] [18748]     0 18748     1079       91       8        0             0 sleep
[   81.234822] [18883]     0 18883     1079       91       8        0             0 sleep
[   81.234825] [18954]     0 18954     1079       91       8        0             0 sleep
[   81.234828] [19001]     0 19001     1079       90       7        0             0 sleep
[   81.234831] [19103]     0 19103     1079       90       8        0             0 sleep
[   81.234833] [19142]     0 19142     1079       91       9        0             0 sleep
[   81.234836] [19288]     0 19288     1079       90       7        0             0 sleep
[   81.234839] [19310]     0 19310     1079       91       8        0             0 sleep
[   81.234842] [19323]     0 19323     1079       90       8        0             0 sleep
[   81.234845] [19413]     0 19413     3010      254      11        0             0 start_nls_agent
[   81.234848] [19416]     0 19416        2        1       1        0             0 start_nls_agent
[   81.234851] [19417]     0 19417     3010      169       8        0             0 start_nls_agent
[   81.234854] [19418]     0 19418     3010      169       9        0             0 start_nls_agent
[   81.234856] [19419]     0 19419     3010      170       9        0             0 start_nls_agent
[   81.234859] [19420]     0 19420     3010      170       9        0             0 start_nls_agent
[   81.234862] [19421]     0 19421     3010      163       8        0             0 start_nls_agent
[   81.234864] [19422]     0 19422     3010      163       8        0             0 start_nls_agent
[   81.234867] Kernel panic - not syncing: Out of memory: compulsory panic_on_oom is enabled

[   81.235005] CPU: 3 PID: 8284 Comm: DefSch0200 Tainted: G           O E ----V-------   3.10.0-229.42.1.105.x86_64 #1
[   81.235005] Hardware name: OpenStack Foundation OpenStack Nova, BIOS rel-1.8.1-0-g4adadbd-20161111_105425-HGH1000008200 04/01/2014
[   81.235005]  ffffffff8183ddc8 000000002b3489d7 ffff880b6cec7c68 ffffffff81608d3d
[   81.235005]  ffff880b6cec7ce8 ffffffff816025de ffff880b00000010 ffff880b6cec7cf8
[   81.248437]  ffff880b6cec7c98 000000002b3489d7 00000000000000a3 ffffffff81841893
[   81.248437] Call Trace:
[   81.252523]  [<ffffffff81608d3d>] dump_stack+0x19/0x1b
[   81.252523]  [<ffffffff816025de>] panic+0xd8/0x214
[   81.252523]  [<ffffffff8115d86f>] check_panic_on_oom+0x5f/0x60
[   81.252523]  [<ffffffff811c17bf>] mem_cgroup_oom_synchronize+0x34f/0x580
[   81.252523]  [<ffffffff811c0db0>] ? mem_cgroup_charge_common+0xc0/0xc0
[   81.252523]  [<ffffffff8115df44>] pagefault_out_of_memory+0x14/0x90
[   81.252523]  [<ffffffff81602104>] mm_fault_error+0x8e/0x180
[   81.261459]  [<ffffffff8161492b>] __do_page_fault+0x44b/0x560
[   81.261459]  [<ffffffff810b34bc>] ? update_curr+0xcc/0x150
[   81.261459]  [<ffffffff8101260b>] ? __switch_to+0x17b/0x4d0
[   81.261459]  [<ffffffff81614af3>] trace_do_page_fault+0x43/0x100
[   81.261459]  [<ffffffff816140e9>] do_async_page_fault+0x29/0xe0
[   81.261459]  [<ffffffff81610b78>] async_page_fault+0x28/0x30
[   81.261459] collected_len = 101708, LOG_BUF_LEN_LOCAL = 1048576
[   81.261459] kbox: no notify die func register. no need to notify

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
