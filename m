Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 8C7756B0044
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 15:35:56 -0400 (EDT)
Date: Thu, 26 Apr 2012 15:35:51 -0400
From: Dave Jones <davej@redhat.com>
Subject: 3.4-rc4 oom killer out of control.
Message-ID: <20120426193551.GA24968@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Linux Kernel <linux-kernel@vger.kernel.org>

On a test machine that was running my system call fuzzer, I just saw
the oom killer take out everything but the process that was doing all
the memory exhausting.

Partial logs below. The machine locked up completely (even capslock wouldn't work).
The console had logs up to 5041.xxxxxx before the wedge, but they never made it to disk.
It was just more of the same below..

Note that the trinity processes have largest RSS, yet seem immune to getting killed.

	Dave


Apr 26 13:56:45 dhcp-189-232 kernel: [ 4959.198003] modprobe invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0, oom_score_adj=0
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.198349] modprobe cpuset=/ mems_allowed=0
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.198705] Pid: 14950, comm: modprobe Not tainted 3.4.0-rc4+ #55
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.199406] Call Trace:
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.200214]  [<ffffffff816ae755>] ? _raw_spin_unlock+0x35/0x60
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.201084]  [<ffffffff816a32a7>] dump_header+0x83/0x2eb
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.201928]  [<ffffffff816ae6da>] ? _raw_spin_unlock_irqrestore+0x4a/0x90
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.202814]  [<ffffffff8132e46c>] ? ___ratelimit+0xac/0x150
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.203687]  [<ffffffff8115b6fc>] oom_kill_process+0x28c/0x2c0
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.204539]  [<ffffffff8115bc29>] out_of_memory+0x239/0x3e0
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.205416]  [<ffffffff81161d7d>] __alloc_pages_nodemask+0xb0d/0xb20
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.206277]  [<ffffffff8119d366>] alloc_pages_current+0xb6/0x120
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.207142]  [<ffffffff811569e7>] __page_cache_alloc+0xb7/0xe0
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.207999]  [<ffffffff81159bbf>] filemap_fault+0x2ff/0x4c0
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.208892]  [<ffffffff8117df8f>] __do_fault+0x6f/0x540
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.209752]  [<ffffffff81180cf0>] handle_pte_fault+0x90/0xa10
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.210633]  [<ffffffff811b7d0f>] ? mem_cgroup_count_vm_event+0x1f/0x1e0
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.211509]  [<ffffffff81181a18>] handle_mm_fault+0x1e8/0x2f0
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.212384]  [<ffffffff816b233b>] do_page_fault+0x16b/0x5d0
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.213475]  [<ffffffff81335a1e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.214137]  [<ffffffff816af019>] ? retint_swapgs+0x13/0x1b
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.215018]  [<ffffffff81335a5d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.215886]  [<ffffffff816af2e5>] page_fault+0x25/0x30
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.216722] Mem-Info:
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.217608] Node 0 DMA per-cpu:
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.218500] CPU    0: hi:    0, btch:   1 usd:   0
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.219400] CPU    1: hi:    0, btch:   1 usd:   0
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.220292] CPU    2: hi:    0, btch:   1 usd:   0
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.221186] CPU    3: hi:    0, btch:   1 usd:   0
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.222067] Node 0 DMA32 per-cpu:
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.222937] CPU    0: hi:  186, btch:  31 usd:  16
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.223833] CPU    1: hi:  186, btch:  31 usd:   7
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.224692] CPU    2: hi:  186, btch:  31 usd:   1
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.225554] CPU    3: hi:  186, btch:  31 usd:   9
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.226408] Node 0 Normal per-cpu:
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.227253] CPU    0: hi:  186, btch:  31 usd:   2
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.228095] CPU    1: hi:  186, btch:  31 usd:  65
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.228918] CPU    2: hi:  186, btch:  31 usd:  33
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.229767] CPU    3: hi:  186, btch:  31 usd:  21
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.230600] active_anon:1421942 inactive_anon:313560 isolated_anon:0
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.230604]  active_file:88 inactive_file:120 isolated_file:70
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.230608]  unevictable:3038 dirty:7 writeback:0 unstable:0
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.230610]  free:25574 slab_reclaimable:14238 slab_unreclaimable:101544
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.230611]  mapped:232 shmem:86 pagetables:89711 bounce:0
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.234745] Node 0 DMA free:15876kB min:128kB low:160kB high:192kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15652kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:32kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.237548] lowmem_reserve[]: 0 3246 8034 8034
Apr 26 13:56:48 dhcp-189-232 kernel: [ 4959.238522] Node 0 DMA32 free:46340kB min:27252kB low:34064kB high:40876kB active_anon:2330464kB inactive_anon:582676kB active_file:16kB inactive_file:44kB unevictable:4748kB isolated(anon):0kB isolated(file):0kB present:3324200kB mlocked:4748kB dirty:0kB writeback:0kB mapped:112kB shmem:104kB slab_reclaimable:2832kB slab_unreclaimable:132232kB kernel_stack:2272kB pagetables:133664kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:42 all_unreclaimable? yes
Apr 26 13:56:50 dhcp-189-232 kernel: [ 4959.241635] lowmem_reserve[]: 0 0 4788 4788
Apr 26 13:57:09 dhcp-189-232 kernel: [ 4959.242701] Node 0 Normal free:40080kB min:40196kB low:50244kB high:60292kB active_anon:3357304kB inactive_anon:671564kB active_file:336kB inactive_file:436kB unevictable:7404kB isolated(anon):0kB isolated(file):280kB present:4902912kB mlocked:7404kB dirty:28kB writeback:0kB mapped:816kB shmem:240kB slab_reclaimable:54120kB slab_unreclaimable:273912kB kernel_stack:4528kB pagetables:225180kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:970 all_unreclaimable? yes
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.246216] lowmem_reserve[]: 0 0 0 0
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.247423] Node 0 DMA: 1*4kB 0*8kB 0*16kB 0*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15876kB
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.248684] Node 0 DMA32: 217*4kB 152*8kB 158*16kB 232*32kB 134*64kB 67*128kB 9*256kB 5*512kB 2*1024kB 1*2048kB 2*4096kB = 46340kB
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.249873] Node 0 Normal: 475*4kB 405*8kB 272*16kB 352*32kB 144*64kB 40*128kB 11*256kB 0*512kB 0*1024kB 1*2048kB 0*4096kB = 39956kB
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.251173] 2037 total pagecache pages
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.252403] 1692 pages in swap cache
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.253630] Swap cache stats: add 1828870, delete 1827178, find 493465/493919
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.254887] Free swap  = 0kB
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.256126] Total swap = 1023996kB
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.347525] 2097136 pages RAM
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.348055] 59776 pages reserved
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.348865] 2554149 pages shared
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.349991] 2007673 pages non-shared
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.351168] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.352382] [  353]     0   353     4425       23   2     -17         -1000 udevd
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.353575] [  355]     0   355     5802        1   2       0             0 systemd-stdout-
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.354796] [  737]     0   737     4766        1   3       0             0 smartd
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.356016] [  751]     0   751    29591       24   0       0             0 crond
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.357246] [  755]     0   755     1616        1   1       0             0 acpid
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.358447] [  756]     0   756    67222      107   0       0             0 NetworkManager
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.359656] [  770]     0   770     7083        1   0       0             0 systemd-logind
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.360879] [  773]    70   773     7005       50   3       0             0 avahi-daemon
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.362082] [  776]    70   776     6972        4   0       0             0 avahi-daemon
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.363301] [  778]     0   778     1612        1   0       0             0 mcelog
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.364526] [  783]   994   783     4893       24   0       0             0 chronyd
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.365748] [  787]    81   787     5472       69   0     -13          -900 dbus-daemon
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.366862] [  790]     0   790    29064       39   0       0             0 ksmtuned
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.368085] [  797]     0   797    46610       31   1     -13          -900 polkitd
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.369305] [  802]     0   802    60782       52   1       0             0 rsyslogd
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.370527] [  815]     0   815    18861        1   0     -17         -1000 sshd
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.371756] [  816]     0   816     8512        1   2       0             0 rpc.idmapd
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.372995] [  819]     0   819     4792       17   2       0             0 rpcbind
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.374229] [  824]    29   824     6938        1   0       0             0 rpc.statd
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.375462] [  837]     0   837    27232        1   3       0             0 agetty
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.376695] [  842]     0   842    21549        1   2       0             0 dhclient
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.377938] [ 1170]  1000  1170     6134       81   0       0             0 tmux
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.379192] [ 1171]  1000  1171    29914        1   2       0             0 bash
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.380455] [ 1262]  1000  1262     4022      125   3       0             0 trinity
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.381709] [ 1325]     0  1325     4424       57   2     -17         -1000 udevd
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.382928] [15065]     0 15065     3725       87   3       0             0 anacron
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.384164] [19925]     0 19925     4424        1   3     -17         -1000 udevd
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.385449] [13786]     0 13786    26704       68   2       0             0 sleep
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.386748] [14941]     0 14941     1629       87   0       0             0 modprobe
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.388042] [14944]     0 14944     1628       63   0       0             0 modprobe
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.389325] [14945]  1000 14945     4418      639   3       0             0 trinity
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.390618] [14950]     0 14950      106        3   2       0             0 modprobe
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.391913] [14952]  1000 14952     4022      203   0       0             0 trinity
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.393252] [14955]  1000 14955     4022      124   0       0             0 trinity
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.394560] Out of memory: Kill process 355 (systemd-stdout-) score 1 or sacrifice child
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4959.395847] Killed process 355 (systemd-stdout-) total-vm:23208kB, anon-rss:0kB, file-rss:4kB
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4961.358425] systemd invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0, oom_score_adj=0
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4961.358956] systemd cpuset=/ mems_allowed=0
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4961.359956] Pid: 1, comm: systemd Not tainted 3.4.0-rc4+ #55
Apr 26 13:57:10 dhcp-189-232 kernel: [ 4961.361271] Call Trace:
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.362557]  [<ffffffff816ae755>] ? _raw_spin_unlock+0x35/0x60
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.363827]  [<ffffffff816a32a7>] dump_header+0x83/0x2eb
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.365052]  [<ffffffff816ae6da>] ? _raw_spin_unlock_irqrestore+0x4a/0x90
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.366208]  [<ffffffff8132e46c>] ? ___ratelimit+0xac/0x150
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.367393]  [<ffffffff8115b6fc>] oom_kill_process+0x28c/0x2c0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.368532]  [<ffffffff8115bc29>] out_of_memory+0x239/0x3e0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.369673]  [<ffffffff81161d7d>] __alloc_pages_nodemask+0xb0d/0xb20
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.370780]  [<ffffffff8119d366>] alloc_pages_current+0xb6/0x120
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.371855]  [<ffffffff811569e7>] __page_cache_alloc+0xb7/0xe0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.372910]  [<ffffffff81159bbf>] filemap_fault+0x2ff/0x4c0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.373935]  [<ffffffff8117df8f>] __do_fault+0x6f/0x540
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.374939]  [<ffffffff81180cf0>] handle_pte_fault+0x90/0xa10
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.375917]  [<ffffffff811b7d0f>] ? mem_cgroup_count_vm_event+0x1f/0x1e0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.376883]  [<ffffffff81181a18>] handle_mm_fault+0x1e8/0x2f0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.377826]  [<ffffffff816b233b>] do_page_fault+0x16b/0x5d0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.378765]  [<ffffffff8120f046>] ? sys_epoll_wait+0x96/0x470
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.379700]  [<ffffffff816b6b15>] ? sysret_check+0x22/0x5d
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.380620]  [<ffffffff81335a5d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.381549]  [<ffffffff816af2e5>] page_fault+0x25/0x30
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.382409] Mem-Info:
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.383329] Node 0 DMA per-cpu:
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.384259] CPU    0: hi:    0, btch:   1 usd:   0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.385200] CPU    1: hi:    0, btch:   1 usd:   0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.386123] CPU    2: hi:    0, btch:   1 usd:   0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.387024] CPU    3: hi:    0, btch:   1 usd:   0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.387898] Node 0 DMA32 per-cpu:
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.388802] CPU    0: hi:  186, btch:  31 usd:   0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.389691] CPU    1: hi:  186, btch:  31 usd:  30
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.390587] CPU    2: hi:  186, btch:  31 usd:   0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.391466] CPU    3: hi:  186, btch:  31 usd:   0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.392334] Node 0 Normal per-cpu:
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.393198] CPU    0: hi:  186, btch:  31 usd:  75
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.394078] CPU    1: hi:  186, btch:  31 usd:  30
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.394934] CPU    2: hi:  186, btch:  31 usd:  22
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.395810] CPU    3: hi:  186, btch:  31 usd:   0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.396663] active_anon:1421870 inactive_anon:313545 isolated_anon:0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.396664]  active_file:103 inactive_file:50 isolated_file:64
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.396665]  unevictable:3038 dirty:7 writeback:0 unstable:0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.396666]  free:25649 slab_reclaimable:14238 slab_unreclaimable:101538
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.396668]  mapped:237 shmem:86 pagetables:89658 bounce:0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.400859] Node 0 DMA free:15876kB min:128kB low:160kB high:192kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15652kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:32kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.403671] lowmem_reserve[]: 0 3246 8034 8034
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.404653] Node 0 DMA32 free:46192kB min:27252kB low:34064kB high:40876kB active_anon:2330460kB inactive_anon:582672kB active_file:0kB inactive_file:96kB unevictable:4748kB isolated(anon):0kB isolated(file):0kB present:3324200kB mlocked:4748kB dirty:0kB writeback:0kB mapped:108kB shmem:104kB slab_reclaimable:2832kB slab_unreclaimable:132232kB kernel_stack:2272kB pagetables:133664kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.407764] lowmem_reserve[]: 0 0 4788 4788
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.408824] Node 0 Normal free:40528kB min:40196kB low:50244kB high:60292kB active_anon:3357020kB inactive_anon:671508kB active_file:412kB inactive_file:104kB unevictable:7404kB isolated(anon):0kB isolated(file):256kB present:4902912kB mlocked:7404kB dirty:28kB writeback:0kB mapped:840kB shmem:240kB slab_reclaimable:54120kB slab_unreclaimable:273888kB kernel_stack:4528kB pagetables:224968kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:23 all_unreclaimable? no
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.412250] lowmem_reserve[]: 0 0 0 0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.413420] Node 0 DMA: 1*4kB 0*8kB 0*16kB 0*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15876kB
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.414664] Node 0 DMA32: 226*4kB 155*8kB 160*16kB 229*32kB 134*64kB 67*128kB 9*256kB 5*512kB 2*1024kB 1*2048kB 2*4096kB = 46336kB
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.415839] Node 0 Normal: 542*4kB 428*8kB 273*16kB 353*32kB 145*64kB 40*128kB 11*256kB 0*512kB 0*1024kB 1*2048kB 0*4096kB = 40520kB
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.417112] 2026 total pagecache pages
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.418352] 1685 pages in swap cache
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.419591] Swap cache stats: add 1828918, delete 1827233, find 493469/493923
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.420839] Free swap  = 0kB
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.422068] Total swap = 1023996kB
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.502902] 2097136 pages RAM
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.503469] 59776 pages reserved
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.504253] 2553433 pages shared
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.505446] 2007548 pages non-shared
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.506614] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.507848] [  353]     0   353     4425       23   2     -17         -1000 udevd
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.509055] [  737]     0   737     4766        1   3       0             0 smartd
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.510247] [  751]     0   751    29591       24   0       0             0 crond
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.511462] [  755]     0   755     1616        1   1       0             0 acpid
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.512665] [  756]     0   756    67222      107   1       0             0 NetworkManager
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.513879] [  770]     0   770     7083        1   0       0             0 systemd-logind
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.515077] [  773]    70   773     7005       50   3       0             0 avahi-daemon
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.516211] [  776]    70   776     6972        4   0       0             0 avahi-daemon
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.517431] [  778]     0   778     1612        1   0       0             0 mcelog
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.518630] [  783]   994   783     4893       24   0       0             0 chronyd
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.519848] [  787]    81   787     5472       69   0     -13          -900 dbus-daemon
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.521071] [  790]     0   790    29064       39   0       0             0 ksmtuned
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.522285] [  797]     0   797    46610       31   2     -13          -900 polkitd
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.523503] [  802]     0   802    60782       52   1       0             0 rsyslogd
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.524745] [  815]     0   815    18861        1   0     -17         -1000 sshd
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.525972] [  816]     0   816     8512        1   2       0             0 rpc.idmapd
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.527201] [  819]     0   819     4792       17   2       0             0 rpcbind
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.528428] [  824]    29   824     6938        1   0       0             0 rpc.statd
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.529659] [  837]     0   837    27232        1   3       0             0 agetty
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.530899] [  842]     0   842    21549        1   2       0             0 dhclient
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.532097] [ 1170]  1000  1170     6134       78   2       0             0 tmux
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.533306] [ 1171]  1000  1171    29914        1   2       0             0 bash
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.534547] [ 1262]  1000  1262     4022      125   1       0             0 trinity
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.535816] [ 1325]     0  1325     4424       57   2     -17         -1000 udevd
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.537076] [15065]     0 15065     3725       87   3       0             0 anacron
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.538337] [19925]     0 19925     4424        1   3     -17         -1000 udevd
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.539605] [13786]     0 13786    26704       68   2       0             0 sleep
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.540888] [14941]     0 14941     1629       87   1       0             0 modprobe
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.542179] [14944]     0 14944     1628       63   1       0             0 modprobe
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.543473] [14945]  1000 14945     4418      652   2       0             0 trinity
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.544756] [14950]     0 14950      106        7   3       0             0 modprobe
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.546051] [14955]  1000 14955     4022      124   2       0             0 trinity
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.547353] Out of memory: Kill process 737 (smartd) score 1 or sacrifice child
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4961.548644] Killed process 737 (smartd) total-vm:19064kB, anon-rss:0kB, file-rss:4kB
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.791375] trinity invoked oom-killer: gfp_mask=0x280da, order=0, oom_adj=0, oom_score_adj=0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.791871] trinity cpuset=/ mems_allowed=0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.792948] Pid: 14972, comm: trinity Not tainted 3.4.0-rc4+ #55
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.794230] Call Trace:
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.795559]  [<ffffffff816ae755>] ? _raw_spin_unlock+0x35/0x60
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.796866]  [<ffffffff816a32a7>] dump_header+0x83/0x2eb
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.798155]  [<ffffffff816ae6da>] ? _raw_spin_unlock_irqrestore+0x4a/0x90
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.799432]  [<ffffffff8132e46c>] ? ___ratelimit+0xac/0x150
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.800679]  [<ffffffff8115b6fc>] oom_kill_process+0x28c/0x2c0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.801892]  [<ffffffff8115bc29>] out_of_memory+0x239/0x3e0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.803092]  [<ffffffff81161d7d>] __alloc_pages_nodemask+0xb0d/0xb20
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.804244]  [<ffffffff8119fdb3>] alloc_pages_vma+0xb3/0x190
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.805393]  [<ffffffff81181300>] handle_pte_fault+0x6a0/0xa10
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.806510]  [<ffffffff810a2981>] ? get_parent_ip+0x11/0x50
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.807590]  [<ffffffff816b2b2d>] ? sub_preempt_count+0x9d/0xd0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.807596]  [<ffffffff816ae755>] ? _raw_spin_unlock+0x35/0x60
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.807602]  [<ffffffff811b4f68>] do_huge_pmd_anonymous_page+0xc8/0x380
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.807607]  [<ffffffff81181976>] handle_mm_fault+0x146/0x2f0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.807610]  [<ffffffff816b233b>] do_page_fault+0x16b/0x5d0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.807614]  [<ffffffff811871d6>] ? do_brk+0x246/0x360
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.807619]  [<ffffffff81335a5d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.807623]  [<ffffffff816af2e5>] page_fault+0x25/0x30
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.807627] Mem-Info:
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.807630] Node 0 DMA per-cpu:
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.807633] CPU    0: hi:    0, btch:   1 usd:   0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.807637] CPU    1: hi:    0, btch:   1 usd:   0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.807639] CPU    2: hi:    0, btch:   1 usd:   0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.807641] CPU    3: hi:    0, btch:   1 usd:   0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.807643] Node 0 DMA32 per-cpu:
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.807646] CPU    0: hi:  186, btch:  31 usd:   1
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.807648] CPU    1: hi:  186, btch:  31 usd:   0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.807651] CPU    2: hi:  186, btch:  31 usd:   3
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.807653] CPU    3: hi:  186, btch:  31 usd:   1
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.807655] Node 0 Normal per-cpu:
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.807658] CPU    0: hi:  186, btch:  31 usd:   0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.807660] CPU    1: hi:  186, btch:  31 usd:   0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.807662] CPU    2: hi:  186, btch:  31 usd:   0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.807664] CPU    3: hi:  186, btch:  31 usd:   0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.807670] active_anon:1421827 inactive_anon:313613 isolated_anon:0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.807672]  active_file:63 inactive_file:73 isolated_file:110
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.807673]  unevictable:3038 dirty:7 writeback:0 unstable:0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.807674]  free:25681 slab_reclaimable:14174 slab_unreclaimable:101572
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.807675]  mapped:229 shmem:86 pagetables:89725 bounce:0
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.807677] Node 0 DMA free:15876kB min:128kB low:160kB high:192kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15652kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:32kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.807687] lowmem_reserve[]: 0 3246 8034 8034
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.807692] Node 0 DMA32 free:46508kB min:27252kB low:34064kB high:40876kB active_anon:2330216kB inactive_anon:582636kB active_file:24kB inactive_file:28kB unevictable:4748kB isolated(anon):0kB isolated(file):0kB present:3324200kB mlocked:4748kB dirty:0kB writeback:0kB mapped:104kB shmem:104kB slab_reclaimable:2832kB slab_unreclaimable:132256kB kernel_stack:2296kB pagetables:133680kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:83 all_unreclaimable? yes
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.807702] lowmem_reserve[]: 0 0 4788 4788
Apr 26 13:57:14 dhcp-189-232 systemd[1]: systemd-stdout-syslog-bridge.service: main process exited, code=killed, status=9
Apr 26 13:57:11 dhcp-189-232 kernel: [ 4975.807706] Node 0 Normal free:40340kB min:40196kB low:50244kB high:60292kB active_anon:3357092kB inactive_anon:671816kB active_file:228kB inactive_file:264kB unevictable:7404kB isolated(anon):0kB isolated(file):440kB present:4902912kB mlocked:7404kB dirty:28kB writeback:0kB mapped:812kB shmem:240kB slab_reclaimable:53864kB slab_unreclaimable:274000kB kernel_stack:4576kB pagetables:225220kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:770 all_unreclaimable? yes
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.807717] lowmem_reserve[]: 0 0 0 0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.807720] Node 0 DMA: 1*4kB 0*8kB 0*16kB 0*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15876kB
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.807731] Node 0 DMA32: 219*4kB 156*8kB 166*16kB 230*32kB 135*64kB 67*128kB 9*256kB 5*512kB 2*1024kB 1*2048kB 2*4096kB = 46508kB
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.807742] Node 0 Normal: 517*4kB 412*8kB 266*16kB 350*32kB 145*64kB 42*128kB 11*256kB 0*512kB 0*1024kB 1*2048kB 0*4096kB = 40340kB
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.807752] 1526 total pagecache pages
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.807754] 1249 pages in swap cache
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.807757] Swap cache stats: add 1829703, delete 1828454, find 493950/494458
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.807759] Free swap  = 0kB
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.807760] Total swap = 1023996kB
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.924517] 2097136 pages RAM
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.925073] 59776 pages reserved
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.925829] 2551230 pages shared
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.927017] 2007729 pages non-shared
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.928103] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.929299] [  353]     0   353     4425       23   2     -17         -1000 udevd
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.930485] [  751]     0   751    29591       24   0       0             0 crond
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.931669] [  755]     0   755     1616        1   1       0             0 acpid
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.932860] [  756]     0   756    67222      107   1       0             0 NetworkManager
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.934065] [  770]     0   770     7083        1   0       0             0 systemd-logind
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.935251] [  773]    70   773     7005       50   3       0             0 avahi-daemon
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.936454] [  776]    70   776     6972        4   0       0             0 avahi-daemon
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.937669] [  778]     0   778     1612        1   0       0             0 mcelog
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.938838] [  783]   994   783     4893       24   0       0             0 chronyd
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.940037] [  787]    81   787     5472       69   0     -13          -900 dbus-daemon
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.941223] [  790]     0   790    29064       39   0       0             0 ksmtuned
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.942428] [  797]     0   797    46610       31   0     -13          -900 polkitd
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.943620] [  802]     0   802    60782       59   1       0             0 rsyslogd
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.944740] [  815]     0   815    18861        1   0     -17         -1000 sshd
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.945960] [  816]     0   816     8512        1   2       0             0 rpc.idmapd
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.947173] [  819]     0   819     4792       17   3       0             0 rpcbind
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.948373] [  824]    29   824     6938        1   0       0             0 rpc.statd
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.949594] [  837]     0   837    27232        1   3       0             0 agetty
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.950802] [  842]     0   842    21549        1   2       0             0 dhclient
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.952021] [ 1170]  1000  1170     6133       77   0       0             0 tmux
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.953241] [ 1171]  1000  1171    29914        1   2       0             0 bash
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.954555] [ 1262]  1000  1262     4022      125   2       0             0 trinity
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.955715] [ 1325]     0  1325     4424       57   2     -17         -1000 udevd
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.956971] [15065]     0 15065     3725       87   3       0             0 anacron
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.958231] [19925]     0 19925     4424        1   3     -17         -1000 udevd
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.959476] [14944]     0 14944     1629       86   1       0             0 modprobe
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.960698] [14950]     0 14950     1595       57   2       0             0 modprobe
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.961949] [14954]     0 14954     1595       36   2       0             0 modprobe
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.963230] [14958]     0 14958     2810       19   2       0             0 systemd-cgroups
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.964494] [14961]  1000 14961     4286      459   1       0             0 trinity
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.965773] [14965]     0 14965     1618       15   0       0             0 modprobe
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.967069] [14966]     0 14966     2290       19   1       0             0 systemd-cgroups
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.968363] [14967]     0 14967     1621       35   1       0             0 modprobe
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.969669] [14970]     0 14970     1595       58   0       0             0 modprobe
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.970972] [14972]  1000 14972     4220      456   3       0             0 trinity
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.972269] [14975]     0 14975      104        1   2       0             0 modprobe
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.973563] Out of memory: Kill process 751 (crond) score 1 or sacrifice child
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4975.974863] Killed process 751 (crond) total-vm:118364kB, anon-rss:92kB, file-rss:4kB
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.036332] systemd-cgroups invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0, oom_score_adj=0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.036811] systemd-cgroups cpuset=/ mems_allowed=0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.037772] Pid: 14958, comm: systemd-cgroups Not tainted 3.4.0-rc4+ #55
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.039032] Call Trace:
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.040280]  [<ffffffff816ae755>] ? _raw_spin_unlock+0x35/0x60
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.041507]  [<ffffffff816a32a7>] dump_header+0x83/0x2eb
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.042610]  [<ffffffff816ae6da>] ? _raw_spin_unlock_irqrestore+0x4a/0x90
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.043793]  [<ffffffff8132e46c>] ? ___ratelimit+0xac/0x150
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.044947]  [<ffffffff8115b6fc>] oom_kill_process+0x28c/0x2c0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.046063]  [<ffffffff8115bc29>] out_of_memory+0x239/0x3e0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.047156]  [<ffffffff81161d7d>] __alloc_pages_nodemask+0xb0d/0xb20
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.048226]  [<ffffffff8119d366>] alloc_pages_current+0xb6/0x120
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.049259]  [<ffffffff811569e7>] __page_cache_alloc+0xb7/0xe0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.050282]  [<ffffffff81159bbf>] filemap_fault+0x2ff/0x4c0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.051270]  [<ffffffff8117df8f>] __do_fault+0x6f/0x540
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.052234]  [<ffffffff81180cf0>] handle_pte_fault+0x90/0xa10
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.053175]  [<ffffffff811b7d0f>] ? mem_cgroup_count_vm_event+0x1f/0x1e0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.054132]  [<ffffffff81181a18>] handle_mm_fault+0x1e8/0x2f0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.055081]  [<ffffffff816b233b>] do_page_fault+0x16b/0x5d0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.056015]  [<ffffffff811c1453>] ? sys_close+0x43/0x1a0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.056940]  [<ffffffff81335a5d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.057895]  [<ffffffff816af2e5>] page_fault+0x25/0x30
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.058855] Mem-Info:
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.059727] Node 0 DMA per-cpu:
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.060674] CPU    0: hi:    0, btch:   1 usd:   0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.061619] CPU    1: hi:    0, btch:   1 usd:   0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.062547] CPU    2: hi:    0, btch:   1 usd:   0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.063456] CPU    3: hi:    0, btch:   1 usd:   0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.064373] Node 0 DMA32 per-cpu:
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.065269] CPU    0: hi:  186, btch:  31 usd:   0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.066178] CPU    1: hi:  186, btch:  31 usd:   0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.067069] CPU    2: hi:  186, btch:  31 usd:   0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.067947] CPU    3: hi:  186, btch:  31 usd:   0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.068854] Node 0 Normal per-cpu:
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.069730] CPU    0: hi:  186, btch:  31 usd:   0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.070587] CPU    1: hi:  186, btch:  31 usd:   0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.071458] CPU    2: hi:  186, btch:  31 usd:   0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.072321] CPU    3: hi:  186, btch:  31 usd:   0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.073165] active_anon:1421858 inactive_anon:313540 isolated_anon:0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.073166]  active_file:94 inactive_file:65 isolated_file:151
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.073167]  unevictable:3038 dirty:9 writeback:0 unstable:0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.073170]  free:25544 slab_reclaimable:14174 slab_unreclaimable:101572
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.073172]  mapped:229 shmem:86 pagetables:89708 bounce:0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.077353] Node 0 DMA free:15876kB min:128kB low:160kB high:192kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15652kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:32kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.080149] lowmem_reserve[]: 0 3246 8034 8034
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.081123] Node 0 DMA32 free:46240kB min:27252kB low:34064kB high:40876kB active_anon:2330228kB inactive_anon:582636kB active_file:28kB inactive_file:36kB unevictable:4748kB isolated(anon):0kB isolated(file):0kB present:3324200kB mlocked:4748kB dirty:8kB writeback:0kB mapped:104kB shmem:104kB slab_reclaimable:2832kB slab_unreclaimable:132256kB kernel_stack:2288kB pagetables:133684kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:5 all_unreclaimable? no
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.084201] lowmem_reserve[]: 0 0 4788 4788
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.085253] Node 0 Normal free:40060kB min:40196kB low:50244kB high:60292kB active_anon:3357204kB inactive_anon:671524kB active_file:348kB inactive_file:224kB unevictable:7404kB isolated(anon):0kB isolated(file):604kB present:4902912kB mlocked:7404kB dirty:28kB writeback:0kB mapped:812kB shmem:240kB slab_reclaimable:53864kB slab_unreclaimable:274000kB kernel_stack:4600kB pagetables:225148kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:28 all_unreclaimable? no
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.088669] lowmem_reserve[]: 0 0 0 0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.089845] Node 0 DMA: 1*4kB 0*8kB 0*16kB 0*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15876kB
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.091098] Node 0 DMA32: 204*4kB 143*8kB 161*16kB 231*32kB 136*64kB 67*128kB 9*256kB 5*512kB 2*1024kB 1*2048kB 2*4096kB = 46360kB
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.092319] Node 0 Normal: 565*4kB 415*8kB 265*16kB 350*32kB 145*64kB 42*128kB 11*256kB 0*512kB 0*1024kB 1*2048kB 0*4096kB = 40540kB
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.093613] 1616 total pagecache pages
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.094829] 1336 pages in swap cache
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.096071] Swap cache stats: add 1829817, delete 1828481, find 493950/494458
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.097332] Free swap  = 0kB
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.098596] Total swap = 1023996kB
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.205067] 2097136 pages RAM
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.205470] 59776 pages reserved
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206413] 2549841 pages shared
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206415] 2007690 pages non-shared
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206418] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206444] [  353]     0   353     4425       23   2     -17         -1000 udevd
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206459] [  755]     0   755     1616        1   1       0             0 acpid
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206465] [  756]     0   756    67222      107   1       0             0 NetworkManager
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206470] [  770]     0   770     7083        1   0       0             0 systemd-logind
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206475] [  773]    70   773     7005       50   3       0             0 avahi-daemon
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206480] [  776]    70   776     6972        4   0       0             0 avahi-daemon
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206485] [  778]     0   778     1612        1   0       0             0 mcelog
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206490] [  783]   994   783     4893       24   0       0             0 chronyd
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206495] [  787]    81   787     5472       69   0     -13          -900 dbus-daemon
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206500] [  790]     0   790    29064       39   2       0             0 ksmtuned
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206505] [  797]     0   797    46610       31   1     -13          -900 polkitd
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206510] [  802]     0   802    60782       59   1       0             0 rsyslogd
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206515] [  815]     0   815    18861        1   0     -17         -1000 sshd
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206520] [  816]     0   816     8512        1   2       0             0 rpc.idmapd
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206524] [  819]     0   819     4792       17   3       0             0 rpcbind
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206529] [  824]    29   824     6938        1   0       0             0 rpc.statd
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206534] [  837]     0   837    27232        1   3       0             0 agetty
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206539] [  842]     0   842    21549        1   2       0             0 dhclient
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206544] [ 1170]  1000  1170     6133       77   2       0             0 tmux
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206549] [ 1171]  1000  1171    29914        1   2       0             0 bash
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206554] [ 1262]  1000  1262     4022      125   3       0             0 trinity
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206559] [ 1325]     0  1325     4424       57   2     -17         -1000 udevd
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206565] [15065]     0 15065     3725       87   3       0             0 anacron
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206573] [19925]     0 19925     4424        1   3     -17         -1000 udevd
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206581] [14944]     0 14944     1629       86   3       0             0 modprobe
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206585] [14950]     0 14950     1628       63   2       0             0 modprobe
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206590] [14954]     0 14954     1595       36   3       0             0 modprobe
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206596] [14958]     0 14958     2810       20   0       0             0 systemd-cgroups
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206600] [14961]  1000 14961     4286      459   1       0             0 trinity
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206606] [14965]     0 14965     1618       15   1       0             0 modprobe
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206610] [14966]     0 14966     2290       19   3       0             0 systemd-cgroups
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206615] [14967]     0 14967     1621       35   1       0             0 modprobe
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206620] [14970]     0 14970     1628       62   2       0             0 modprobe
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206625] [14972]  1000 14972     4286      529   3       0             0 trinity
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206631] [14975]     0 14975      106        8   2       0             0 modprobe
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206636] Out of memory: Kill process 755 (acpid) score 1 or sacrifice child
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4981.206640] Killed process 755 (acpid) total-vm:6464kB, anon-rss:0kB, file-rss:4kB
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.882053] trinity invoked oom-killer: gfp_mask=0x280da, order=0, oom_adj=0, oom_score_adj=0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.882827] trinity cpuset=/ mems_allowed=0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.883513] Pid: 14972, comm: trinity Not tainted 3.4.0-rc4+ #55
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.884768] Call Trace:
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.886025]  [<ffffffff816ae775>] ? _raw_spin_unlock+0x55/0x60
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.887232]  [<ffffffff816a32a7>] dump_header+0x83/0x2eb
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.888433]  [<ffffffff816ae6da>] ? _raw_spin_unlock_irqrestore+0x4a/0x90
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.889579]  [<ffffffff8132e46c>] ? ___ratelimit+0xac/0x150
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.890703]  [<ffffffff8115b6fc>] oom_kill_process+0x28c/0x2c0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.891787]  [<ffffffff8115bc29>] out_of_memory+0x239/0x3e0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.892873]  [<ffffffff81161d7d>] __alloc_pages_nodemask+0xb0d/0xb20
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.893940]  [<ffffffff8119fdb3>] alloc_pages_vma+0xb3/0x190
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.894969]  [<ffffffff81181300>] handle_pte_fault+0x6a0/0xa10
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.895959]  [<ffffffff811b7d0f>] ? mem_cgroup_count_vm_event+0x1f/0x1e0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.896952]  [<ffffffff81181a18>] handle_mm_fault+0x1e8/0x2f0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.897917]  [<ffffffff816b233b>] do_page_fault+0x16b/0x5d0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.898874]  [<ffffffff811871d6>] ? do_brk+0x246/0x360
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.899797]  [<ffffffff81335a5d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.900733]  [<ffffffff816af2e5>] page_fault+0x25/0x30
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.901645] Mem-Info:
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.902542] Node 0 DMA per-cpu:
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.903447] CPU    0: hi:    0, btch:   1 usd:   0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.904352] CPU    1: hi:    0, btch:   1 usd:   0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.905264] CPU    2: hi:    0, btch:   1 usd:   0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.906166] CPU    3: hi:    0, btch:   1 usd:   0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.907061] Node 0 DMA32 per-cpu:
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.907881] CPU    0: hi:  186, btch:  31 usd:   0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.908779] CPU    1: hi:  186, btch:  31 usd:   0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.909655] CPU    2: hi:  186, btch:  31 usd:   0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.910525] CPU    3: hi:  186, btch:  31 usd:   0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.911379] Node 0 Normal per-cpu:
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.912233] CPU    0: hi:  186, btch:  31 usd:   1
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.913091] CPU    1: hi:  186, btch:  31 usd:   4
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.913930] CPU    2: hi:  186, btch:  31 usd:   0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.914792] CPU    3: hi:  186, btch:  31 usd:   0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.915639] active_anon:1421866 inactive_anon:313517 isolated_anon:0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.915641]  active_file:86 inactive_file:127 isolated_file:114
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.915642]  unevictable:3038 dirty:9 writeback:0 unstable:0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.915643]  free:25566 slab_reclaimable:14174 slab_unreclaimable:101572
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.915644]  mapped:229 shmem:86 pagetables:89704 bounce:0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.919846] Node 0 DMA free:15876kB min:128kB low:160kB high:192kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15652kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:32kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.922609] lowmem_reserve[]: 0 3246 8034 8034
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.923570] Node 0 DMA32 free:46384kB min:27252kB low:34064kB high:40876kB active_anon:2330352kB inactive_anon:582628kB active_file:0kB inactive_file:64kB unevictable:4748kB isolated(anon):0kB isolated(file):0kB present:3324200kB mlocked:4748kB dirty:8kB writeback:0kB mapped:104kB shmem:104kB slab_reclaimable:2832kB slab_unreclaimable:132256kB kernel_stack:2280kB pagetables:133684kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:228 all_unreclaimable? yes
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.926571] lowmem_reserve[]: 0 0 4788 4788
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.927617] Node 0 Normal free:40004kB min:40196kB low:50244kB high:60292kB active_anon:3357112kB inactive_anon:671440kB active_file:344kB inactive_file:444kB unevictable:7404kB isolated(anon):0kB isolated(file):456kB present:4902912kB mlocked:7404kB dirty:28kB writeback:0kB mapped:812kB shmem:240kB slab_reclaimable:53864kB slab_unreclaimable:274000kB kernel_stack:4600kB pagetables:225132kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:12 all_unreclaimable? no
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.931017] lowmem_reserve[]: 0 0 0 0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.932183] Node 0 DMA: 1*4kB 0*8kB 0*16kB 0*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15876kB
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.933420] Node 0 DMA32: 206*4kB 145*8kB 161*16kB 231*32kB 136*64kB 67*128kB 9*256kB 5*512kB 2*1024kB 1*2048kB 2*4096kB = 46384kB
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.934698] Node 0 Normal: 506*4kB 408*8kB 263*16kB 351*32kB 145*64kB 42*128kB 11*256kB 0*512kB 0*1024kB 1*2048kB 0*4096kB = 40248kB
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.935988] 1630 total pagecache pages
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.937219] 1286 pages in swap cache
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.938456] Swap cache stats: add 1829855, delete 1828569, find 493952/494460
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.939701] Free swap  = 0kB
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4985.940881] Total swap = 1023996kB
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.024043] 2097136 pages RAM
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.024445] 59776 pages reserved
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.025432] 2548364 pages shared
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.026651] 2007726 pages non-shared
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.027872] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.029123] [  353]     0   353     4425       23   2     -17         -1000 udevd
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.030346] [  756]     0   756    67222      111   0       0             0 NetworkManager
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.031539] [  770]     0   770     7083        1   0       0             0 systemd-logind
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.032769] [  773]    70   773     7005       50   3       0             0 avahi-daemon
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.034004] [  776]    70   776     6972        4   0       0             0 avahi-daemon
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.035225] [  778]     0   778     1612        1   0       0             0 mcelog
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.036452] [  783]   994   783     4893       24   0       0             0 chronyd
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.037654] [  787]    81   787     5472       69   0     -13          -900 dbus-daemon
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.038878] [  790]     0   790    29064       39   1       0             0 ksmtuned
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.040105] [  797]     0   797    46610       39   2     -13          -900 polkitd
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.041252] [  802]     0   802    60782       59   1       0             0 rsyslogd
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.042478] [  815]     0   815    18861        1   0     -17         -1000 sshd
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.043706] [  816]     0   816     8512        1   2       0             0 rpc.idmapd
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.044954] [  819]     0   819     4792       17   3       0             0 rpcbind
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.046187] [  824]    29   824     6938        1   0       0             0 rpc.statd
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.047426] [  837]     0   837    27232        1   3       0             0 agetty
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.048669] [  842]     0   842    21549        1   2       0             0 dhclient
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.049899] [ 1170]  1000  1170     6133       77   2       0             0 tmux
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.051132] [ 1171]  1000  1171    29914        1   2       0             0 bash
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.052362] [ 1262]  1000  1262     4022      125   2       0             0 trinity
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.053596] [ 1325]     0  1325     4424       57   2     -17         -1000 udevd
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.054842] [15065]     0 15065     3725       87   3       0             0 anacron
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.056115] [19925]     0 19925     4424        1   3     -17         -1000 udevd
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.057359] [14944]     0 14944     1629       86   2       0             0 modprobe
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.058602] [14950]     0 14950     1628       65   2       0             0 modprobe
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.059853] [14954]     0 14954     1595       36   1       0             0 modprobe
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.061136] [14958]     0 14958     2810       20   1       0             0 systemd-cgroups
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.062414] [14961]  1000 14961     4286      459   0       0             0 trinity
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.063716] [14965]     0 14965     1618       16   2       0             0 modprobe
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.065015] [14966]     0 14966     2290       19   2       0             0 systemd-cgroups
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.066295] [14967]     0 14967     1595       37   0       0             0 modprobe
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.067591] [14970]     0 14970     1628       65   1       0             0 modprobe
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.068897] [14972]  1000 14972     4286      521   3       0             0 trinity
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.070217] [14975]     0 14975      106        8   1       0             0 modprobe
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.071527] [14979]  1000 14979     4022      125   1       0             0 trinity
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.072832] Out of memory: Kill process 756 (NetworkManager) score 1 or sacrifice child
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4986.074110] Killed process 842 (dhclient) total-vm:86196kB, anon-rss:0kB, file-rss:4kB
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.242452] systemd-cgroups invoked oom-killer: gfp_mask=0x200da, order=0, oom_adj=0, oom_score_adj=0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.242915] systemd-cgroups cpuset=/ mems_allowed=0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.243952] Pid: 14958, comm: systemd-cgroups Not tainted 3.4.0-rc4+ #55
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.245244] Call Trace:
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.246511]  [<ffffffff816ae755>] ? _raw_spin_unlock+0x35/0x60
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.247766]  [<ffffffff816a32a7>] dump_header+0x83/0x2eb
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.248996]  [<ffffffff816ae6da>] ? _raw_spin_unlock_irqrestore+0x4a/0x90
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.250204]  [<ffffffff8132e46c>] ? ___ratelimit+0xac/0x150
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.251350]  [<ffffffff8115b6fc>] oom_kill_process+0x28c/0x2c0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.252505]  [<ffffffff8115bc29>] out_of_memory+0x239/0x3e0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.253627]  [<ffffffff81161d7d>] __alloc_pages_nodemask+0xb0d/0xb20
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.254720]  [<ffffffff816b2b2d>] ? sub_preempt_count+0x9d/0xd0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.255793]  [<ffffffff8119fdb3>] alloc_pages_vma+0xb3/0x190
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.256780]  [<ffffffff8117e248>] __do_fault+0x328/0x540
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.257795]  [<ffffffff81180cf0>] handle_pte_fault+0x90/0xa10
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.258789]  [<ffffffff811b7d0f>] ? mem_cgroup_count_vm_event+0x1f/0x1e0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.259769]  [<ffffffff81181a18>] handle_mm_fault+0x1e8/0x2f0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.260734]  [<ffffffff816b233b>] do_page_fault+0x16b/0x5d0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.261697]  [<ffffffff81335a5d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.262650]  [<ffffffff816af2e5>] page_fault+0x25/0x30
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.263586] Mem-Info:
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.264522] Node 0 DMA per-cpu:
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.265473] CPU    0: hi:    0, btch:   1 usd:   0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.266423] CPU    1: hi:    0, btch:   1 usd:   0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.267372] CPU    2: hi:    0, btch:   1 usd:   0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.268309] CPU    3: hi:    0, btch:   1 usd:   0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.269234] Node 0 DMA32 per-cpu:
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.270149] CPU    0: hi:  186, btch:  31 usd:   2
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.271066] CPU    1: hi:  186, btch:  31 usd:   1
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.271957] CPU    2: hi:  186, btch:  31 usd:   0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.272856] CPU    3: hi:  186, btch:  31 usd:  30
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.273681] Node 0 Normal per-cpu:
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.274571] CPU    0: hi:  186, btch:  31 usd: 100
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.275466] CPU    1: hi:  186, btch:  31 usd:  45
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.276351] CPU    2: hi:  186, btch:  31 usd:  87
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.277222] CPU    3: hi:  186, btch:  31 usd:  41
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.278087] active_anon:1421461 inactive_anon:313478 isolated_anon:0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.278088]  active_file:185 inactive_file:290 isolated_file:69
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.278090]  unevictable:3038 dirty:0 writeback:0 unstable:0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.278091]  free:25550 slab_reclaimable:14134 slab_unreclaimable:101600
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.278092]  mapped:305 shmem:86 pagetables:89707 bounce:0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.282445] Node 0 DMA free:15876kB min:128kB low:160kB high:192kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15652kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:32kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.285312] lowmem_reserve[]: 0 3246 8034 8034
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.286303] Node 0 DMA32 free:46272kB min:27252kB low:34064kB high:40876kB active_anon:2330240kB inactive_anon:582708kB active_file:24kB inactive_file:20kB unevictable:4748kB isolated(anon):0kB isolated(file):0kB present:3324200kB mlocked:4748kB dirty:0kB writeback:0kB mapped:104kB shmem:104kB slab_reclaimable:2800kB slab_unreclaimable:132256kB kernel_stack:2296kB pagetables:133744kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:296 all_unreclaimable? yes
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.289453] lowmem_reserve[]: 0 0 4788 4788
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.290460] Node 0 Normal free:40052kB min:40196kB low:50244kB high:60292kB active_anon:3355604kB inactive_anon:671204kB active_file:716kB inactive_file:1140kB unevictable:7404kB isolated(anon):0kB isolated(file):276kB present:4902912kB mlocked:7404kB dirty:0kB writeback:0kB mapped:1116kB shmem:240kB slab_reclaimable:53736kB slab_unreclaimable:274112kB kernel_stack:4616kB pagetables:225084kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:4068 all_unreclaimable? yes
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.295125] lowmem_reserve[]: 0 0 0 0
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.296327] Node 0 DMA: 1*4kB 0*8kB 0*16kB 0*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15876kB
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.297596] Node 0 DMA32: 179*4kB 143*8kB 158*16kB 229*32kB 136*64kB 67*128kB 9*256kB 5*512kB 2*1024kB 1*2048kB 2*4096kB = 46148kB
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.298883] Node 0 Normal: 449*4kB 360*8kB 263*16kB 353*32kB 150*64kB 42*128kB 10*256kB 0*512kB 0*1024kB 1*2048kB 0*4096kB = 39764kB
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.300186] 2587 total pagecache pages
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.301448] 1924 pages in swap cache
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.302721] Swap cache stats: add 1830963, delete 1829039, find 494366/494878
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.303994] Free swap  = 0kB
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.305280] Total swap = 1023996kB
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.371694] 2097136 pages RAM
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.372170] 59776 pages reserved
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.373070] 2548580 pages shared
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.374252] 2007488 pages non-shared
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.375461] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.376713] [  353]     0   353     4425       23   2     -17         -1000 udevd
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.377924] [  756]     0   756    67222      108   1       0             0 NetworkManager
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.379160] [  770]     0   770     7083        1   0       0             0 systemd-logind
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.380398] [  773]    70   773     7005       50   3       0             0 avahi-daemon
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.381640] [  776]    70   776     6972        4   0       0             0 avahi-daemon
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.382883] [  778]     0   778     1612        1   0       0             0 mcelog
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.384116] [  783]   994   783     4893       24   0       0             0 chronyd
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.385370] [  787]    81   787     5472       69   0     -13          -900 dbus-daemon
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.386595] [  790]     0   790    29064       41   1       0             0 ksmtuned
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.387830] [  797]     0   797    46610       34   2     -13          -900 polkitd
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.389066] [  802]     0   802    60782       63   1       0             0 rsyslogd
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.390244] [  815]     0   815    18861        1   0     -17         -1000 sshd
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.391487] [  816]     0   816     8512        1   2       0             0 rpc.idmapd
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.392739] [  819]     0   819     4792       17   3       0             0 rpcbind
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.393980] [  824]    29   824     6938        1   0       0             0 rpc.statd
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.395227] [  837]     0   837    27232        1   3       0             0 agetty
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.396486] [ 1170]  1000  1170     6133      112   3       0             0 tmux
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.397727] [ 1171]  1000  1171    29914        1   2       0             0 bash
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.398971] [ 1262]  1000  1262     4022      131   1       0             0 trinity
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.400219] [ 1325]     0  1325     4424       57   2     -17         -1000 udevd
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.401493] [15065]     0 15065     3725       87   3       0             0 anacron
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.402759] [19925]     0 19925     4424        1   3     -17         -1000 udevd
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.404053] [14950]     0 14950     1628       89   1       0             0 modprobe
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.405370] [14954]     0 14954     1595       56   3       0             0 modprobe
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.406583] [14958]     0 14958     3763       32   2       0             0 systemd-cgroups
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.407859] [14965]     0 14965     1621       42   2       0             0 modprobe
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.409294] [14966]     0 14966     2810       43   3       0             0 systemd-cgroups
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.410460] [14967]     0 14967     1595       59   1       0             0 modprobe
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.411770] [14970]     0 14970     1628       89   1       0             0 modprobe
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.413072] [14975]     0 14975     1621       55   1       0             0 modprobe
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.414379] [14977]     0 14977     1750       36   2       0             0 systemd-cgroups
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.415685] [14979]  1000 14979     4022      271   1       0             0 trinity
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.417022] [14980]     0 14980     1750       36   0       0             0 systemd-cgroups
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.418337] [14982]     0 14982      666       31   2       0             0 modprobe
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.419660] [14986]  1000 14986     4319      557   2       0             0 trinity
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.420971] [14987]  1000 14987     4022      269   0       0             0 trinity
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.422278] [14988]  1000 14988     4187      402   3       0             0 trinity
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.423520] [14990]     0 14990      666       35   0       0             0 modprobe
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.424793] [14992]     0 14992      104        1   2       0             0 modprobe
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.426033] [14994]     0 14994      104        1   0       0             0 modprobe
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.427247] Out of memory: Kill process 756 (NetworkManager) score 1 or sacrifice child
Apr 26 13:57:15 dhcp-189-232 kernel: [ 4988.428451] Killed process 756 (NetworkManager) total-vm:268888kB, anon-rss:424kB, file-rss:8kB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
