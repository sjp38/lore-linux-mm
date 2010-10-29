Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8C8116B0098
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 08:15:02 -0400 (EDT)
Received: from d06nrmr1707.portsmouth.uk.ibm.com (d06nrmr1707.portsmouth.uk.ibm.com [9.149.39.225])
	by mtagate6.uk.ibm.com (8.13.1/8.13.1) with ESMTP id o9TCEvEN012397
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 12:14:57 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1707.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o9TCEvHO3235974
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 13:14:57 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o9TCEu8n011127
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 06:14:56 -0600
Date: Fri, 29 Oct 2010 14:14:56 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: oom killer question
Message-ID: <20101029121456.GA6896@osiris.boeblingen.de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Hartmut Beinlich <HBEINLIC@de.ibm.com>
List-ID: <linux-mm.kvack.org>

Hello,

I've got an OOM killed rsyslogd where I'm wondering why the oom killer
got involved at all. Looking at the verbose output it looks to me like
there is a lot of swap space and also a lot of reclaimable slab.
Any idea why this happened?

Thanks!

[18132.475583] blast invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0, oom_score_adj=0
[18132.475612] blast cpuset=/ mems_allowed=0
[18132.475616] CPU: 7 Not tainted 2.6.36-45.x.20101028-s390xdefault #1
[18132.475619] Process blast (pid: 8067, task: 000000007a244640, ksp: 000000003dc8f678)
[18132.475623] 000000003dc8f888 000000003dc8f808 0000000000000002 0000000000000000 
[18132.475628]        000000003dc8f8a8 000000003dc8f820 000000003dc8f820 000000000055ee3e 
[18132.475634]        0000000000000000 0000000000000000 0000000000000000 00000000000201da 
[18132.475640]        000000000000000d 000000000000000c 000000003dc8f870 0000000000000000 
[18132.475646]        0000000000000000 0000000000100afa 000000003dc8f808 000000003dc8f848 
[18132.475653] Call Trace:
[18132.475655] ([<0000000000100a02>] show_trace+0xee/0x144)
[18132.475662]  [<00000000001d73d0>] dump_header+0x98/0x298
[18132.475669]  [<00000000001d7a26>] oom_kill_process+0xb6/0x224
[18132.475672]  [<00000000001d7f26>] out_of_memory+0x10e/0x23c
[18132.475676]  [<00000000001ddb80>] __alloc_pages_nodemask+0x9a4/0xa50
[18132.475680]  [<00000000001e0588>] __do_page_cache_readahead+0x1a4/0x334
[18132.475685]  [<00000000001e0758>] ra_submit+0x40/0x54
[18132.475688]  [<00000000001d542a>] filemap_fault+0x45a/0x48c
[18132.475692]  [<00000000001f2a0e>] __do_fault+0x7e/0x5e8
[18132.475696]  [<00000000001f5fc2>] handle_mm_fault+0x24a/0xaa8
[18132.475700]  [<00000000005656e2>] do_dat_exception+0x14e/0x3c8
[18132.475705]  [<0000000000114b38>] pgm_exit+0x0/0x14
[18132.475710]  [<0000000080011132>] 0x80011132
[18132.475717] 2 locks held by blast/8067:
[18132.475719]  #0:  (&mm->mmap_sem){++++++}, at: [<0000000000565672>] do_dat_exception+0xde/0x3c8
[18132.475726]  #1:  (tasklist_lock){.+.+..}, at: [<00000000001d7ebe>] out_of_memory+0xa6/0x23c
[18132.475734] Mem-Info:
[18132.475736] DMA per-cpu:
[18132.475738] CPU    6: hi:  186, btch:  31 usd:   0
[18132.475741] CPU    7: hi:  186, btch:  31 usd:  45
[18132.475744] CPU    8: hi:  186, btch:  31 usd:   0
[18132.475746] CPU    9: hi:  186, btch:  31 usd:   0
[18132.475750] active_anon:29 inactive_anon:13 isolated_anon:25
[18132.475751]  active_file:11 inactive_file:30 isolated_file:52
[18132.475752]  unevictable:1113 dirty:0 writeback:0 unstable:0
[18132.475753]  free:1404 slab_reclaimable:444597 slab_unreclaimable:47097
[18132.475753]  mapped:921 shmem:0 pagetables:558 bounce:0
[18132.475762] DMA free:5616kB min:5752kB low:7188kB high:8628kB active_anon:116kB inactive_anon:52kB active_file:44kB inactive_file:120kB unevictable:4452kB isolated(anon):100kB isolated(file):208kB present:2068480kB mlocked:4452kB dirty:0kB writeback:0kB mapped:3684kB shmem:0kB slab_reclaimable:1778388kB slab_unreclaimable:188388kB kernel_stack:4016kB pagetables:2232kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:542 all_unreclaimable? yes
[18132.475771] lowmem_reserve[]: 0 0 0
[18132.475776] DMA: 1134*4kB 0*8kB 3*16kB 1*32kB 1*64kB 0*128kB 0*256kB 0*512kB 1*1024kB = 5704kB
[18132.475794] 1083 total pagecache pages
[18132.475796] 44 pages in swap cache
[18132.475799] Swap cache stats: add 432029, delete 431985, find 927716/947315
[18132.475801] Free swap  = 7029052kB
[18132.475803] Total swap = 7212140kB
[18132.487992] 524288 pages RAM
[18132.487995] 18890 pages reserved
[18132.488026] 8609 pages shared
[18132.488028] 500207 pages non-shared
[18132.488030] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[18132.488039] [  160]     0   160      787      114   7     -17         -1000 udevd
[18132.488044] [  588]     0   588    56133      151   6       0             0 rsyslogd
[18132.488049] [  598]    32   598      717      122   7       0             0 rpcbind
[18132.488054] [  610]    29   610      737      167   7       0             0 rpc.statd
[18132.488059] [  642]     0   642      788       64  10       0             0 rpc.idmapd
[18132.488064] [  653]    81   653      824       94   6       0             0 dbus-daemon
[18132.488069] [  671]     0   671    66640     1115  10     -16          -941 multipathd
[18132.488074] [  695]    68   695     6703      188   9       0             0 hald
[18132.488079] [  696]     0   696     1079      136   1       0             0 hald-runner
[18132.488084] [  718]     0   718     1879      118   9     -17         -1000 sshd
[18132.488089] [  725]     0   725     1022      155   1       0             0 xinetd
[18132.488094] [  735]     0   735     1859       46  10       0             0 vsftpd
[18132.488098] [  750]     0   750     3216       98   7       0             0 sendmail
[18132.488103] [  758]    51   758     2762       95   9       0             0 sendmail
[18132.488108] [  766]     0   766     1048      143   7       0             0 crond
[18132.488113] [  776]    43   776     1170      154   7       0             0 xfs
[18132.488118] [  786]     0   786      819       77   7       0             0 atd
[18132.488122] [  802]     0   802      557      135   1       0             0 agetty
[18132.488127] [  805]     0   805      557      135   1       0             0 agetty
[18132.488132] [ 8057]     0  8057      973      129   7       0             0 screen
[18132.488137] [ 8064]     0  8064   113629      186   7       0             0 blast
[18132.488142] [ 8169]     0  8169      854      161   8       0             0 enhanced_node_a
[18132.488147] [ 8323]     0  8323      886      160   0       0             0 start_stress.sh
[18132.488152] [ 8341]     0  8341      691      109  10       0             0 stress
[18132.488157] [ 8345]     0  8345      691       24   9       0             0 stress
[18132.488161] [ 8346]     0  8346      691       23   7       0             0 stress
[18132.488166] [ 8348]     0  8348   131764       46   6       0             0 stress
[18132.488171] [ 8349]     0  8349      691       24   7       0             0 stress
[18132.488176] [ 8350]     0  8350      691       24   6       0             0 stress
[18132.488181] [ 8351]     0  8351      691       24   6       0             0 stress
[18132.488186] [ 8352]     0  8352      691       24   6       0             0 stress
[18132.488190] [ 8353]     0  8353      691       24   6       0             0 stress
[18132.488195] [ 8354]     0  8354      691       24   6       0             0 stress
[18132.488199] [ 8355]     0  8355      691       24   6       0             0 stress
[18132.488205] [ 8356]     0  8356      691       24   6       0             0 stress
[18132.488209] [ 8357]     0  8357      691       24   6       0             0 stress
[18132.488214] [ 8359]     0  8359      691       24   6       0             0 stress
[18132.488219] [ 8360]     0  8360      691       24   8       0             0 stress
[18132.488224] [ 8361]     0  8361      691       28   7       0             0 stress
[18132.488228] [ 8362]     0  8362      691       24   8       0             0 stress
[18132.488233] [ 8363]     0  8363      691       26   7       0             0 stress
[18132.488238] [ 8364]     0  8364      691       25   7       0             0 stress
[18132.488242] [ 8365]     0  8365      691       25   7       0             0 stress
[18132.488247] [ 8366]     0  8366      691       25   7       0             0 stress
[18132.488252] [ 8368]     0  8368      691       24   8       0             0 stress
[18132.488257] [ 8369]     0  8369      691       24   8       0             0 stress
[18132.488261] [ 8370]     0  8370      691       24   7       0             0 stress
[18132.488266] [ 8371]     0  8371      691       25   7       0             0 stress
[18132.488271] [ 8372]     0  8372      691       24   8       0             0 stress
[18132.488276] [ 8373]     0  8373      691       28   7       0             0 stress
[18132.488281] [ 8379]     0  8379     2630      232   2       0             0 sshd
[18132.488285] [ 8387]     0  8387      853      164   7       0             0 bash
[18132.488290] [ 8400]     0  8400      555      105   6       0             0 sleep
[18132.488295] [ 8401]     0  8401      854      160   7       0             0 runque.sh
[18132.488300] [ 8414]     0  8414      854      166   4       0             0 my_cpu_on_off_a
[18132.488305] [ 8473]     0  8473      854      160   7       0             0 dmesg.sh
[18132.488309] [21045]     0 21045     2639      233  11       0             0 sshd
[18132.488314] [21419]     0 21419      904      201   9       0             0 bash
[18132.488320] [ 9888]     0  9888      855      165   9       0             0 cpu_all_off_HB.
[18132.488326] [ 9962]     0  9962      786       77   3     -17         -1000 udevd
[18132.488331] [ 9992]     0  9992      786       63   2     -17         -1000 udevd
[18132.488336] [10127]     0 10127      936      176   9     -17         -1000 kdump
[18132.488341] [10148]     0 10148      936        2   9     -17         -1000 kdump
[18132.488346] [10149]     0 10149     1130      157   7       0             0 crond
[18132.488351] [10156]     0 10156      569      146   7       0             0 sadc
[18132.488355] [10182]     0 10182      778      133   7       0             0 ps
[18132.488360] [10183]     0 10183      578      116   7       0             0 egrep
[18132.488365] [10184]     0 10184     1130      158   7       0             0 crond
[18132.488369] [10191]     0 10191      569      146   7       0             0 sadc
[18132.488374] [10193]     0 10193     1130      157   7       0             0 crond
[18132.488379] [10200]     0 10200      569      146   7       0             0 sadc
[18132.488385] [10210]     0 10210     1130      157   7       0             0 crond
[18132.488389] [10217]     0 10217      569      146   7       0             0 sadc
[18132.488394] [10220]     0 10220     1130      157   7       0             0 crond
[18132.488399] [10227]     0 10227      569      146   7       0             0 sadc
[18132.488404] [10232]     0 10232      555      105   7       0             0 sleep
[18132.488408] Out of memory: Kill process 588 (rsyslogd) score 1 or sacrifice child
[18132.488412] Killed process 588 (rsyslogd) total-vm:224532kB, anon-rss:0kB, file-rss:604kB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
