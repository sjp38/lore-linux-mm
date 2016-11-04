Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4FA7A6B028F
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 10:13:28 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id 12so57550446uas.5
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 07:13:28 -0700 (PDT)
Received: from mail-vk0-x22b.google.com (mail-vk0-x22b.google.com. [2607:f8b0:400c:c05::22b])
        by mx.google.com with ESMTPS id y25si4263660uaa.104.2016.11.04.07.13.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Nov 2016 07:13:26 -0700 (PDT)
Received: by mail-vk0-x22b.google.com with SMTP id w194so67853162vkw.2
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 07:13:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <b5b0cef0-8482-e4de-cb81-69a4dd3410fb@suse.cz>
References: <bug-186671-27@https.bugzilla.kernel.org/> <20161103115353.de87ff35756a4ca8b21d2c57@linux-foundation.org>
 <b5b0cef0-8482-e4de-cb81-69a4dd3410fb@suse.cz>
From: E V <eliventer@gmail.com>
Date: Fri, 4 Nov 2016 10:13:25 -0400
Message-ID: <CAJtFHUQcJKSnyQ7t7-eDpiF2C+U23+iWpZ+X6fGEzN8qdbzmtA@mail.gmail.com>
Subject: Re: [Bug 186671] New: OOM on system with just rsync running 32GB of
 ram 30GB of pagecache
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, linux-btrfs <linux-btrfs@vger.kernel.org>

After the system panic'd yesterday I booted back into 4.8.4 and
restarted the rsync's. I'm away on vacation next week, so when I get
back I'll get rc4 or rc5 and try again. In the mean time here's data
from the system running 4.8.4 without problems for about a day. I'm
not familiar with xxd and didn't see a -e option, so used -E:
xxd -E -g8 -c8 /proc/kpagecount | cut -d" " -f2 | sort | uniq -c
8258633 0000000000000000
 216440 0100000000000000
   5576 0200000000000000
    592 0300000000000000
    195 0400000000000000
    184 0500000000000000
    171 0600000000000000
     70 0700000000000000
      3 0800000000000000
     17 0900000000000000
     48 0a00000000000000
     78 0b00000000000000
     33 0c00000000000000
     23 0d00000000000000
     18 0e00000000000000
      3 0f00000000000000
      5 1000000000000000
      2 1100000000000000
      7 1200000000000000
      5 1300000000000000
      2 1400000000000000
     36 1500000000000000
     10 1600000000000000
      6 1700000000000000
      3 1800000000000000
      8 1900000000000000
      4 1a00000000000000
      7 1b00000000000000
      4 1c00000000000000
      5 1d00000000000000
      3 1e00000000000000
     18 1f00000000000000
      9 2000000000000000
      9 2100000000000000
      9 2200000000000000
     19 2300000000000000
     13 2400000000000000
      6 2500000000000000
     13 2600000000000000
     13 2700000000000000
      3 2800000000000000
     16 2900000000000000
      7 2a00000000000000
     21 2b00000000000000
     33 2c00000000000000
     19 2d00000000000000
     54 2e00000000000000
     29 2f00000000000000
     72 3000000000000000
     27 3100000000000000
 102635 81ffffffffffffff

cat /proc/vmstat
nr_free_pages 106970
nr_zone_inactive_anon 110034
nr_zone_active_anon 108424
nr_zone_inactive_file 350017
nr_zone_active_file 2158161
nr_zone_unevictable 0
nr_zone_write_pending 114
nr_mlock 0
nr_slab_reclaimable 4962990
nr_slab_unreclaimable 415089
nr_page_table_pages 2149
nr_kernel_stack 6176
nr_bounce 0
numa_hit 403780590
numa_miss 176970926
numa_foreign 176970926
numa_interleave 19415
numa_local 403780590
numa_other 0
nr_free_cma 0
nr_inactive_anon 110034
nr_active_anon 108424
nr_inactive_file 350017
nr_active_file 2158161
nr_unevictable 0
nr_isolated_anon 0
nr_isolated_file 0
nr_pages_scanned 0
workingset_refault 1443060
workingset_activate 558143
workingset_nodereclaim 6879280
nr_anon_pages 216243
nr_mapped 6462
nr_file_pages 2510544
nr_dirty 114
nr_writeback 0
nr_writeback_temp 0
nr_shmem 2179
nr_shmem_hugepages 0
nr_shmem_pmdmapped 0
nr_anon_transparent_hugepages 0
nr_unstable 0
nr_vmscan_write 1127
nr_vmscan_immediate_reclaim 19056
nr_dirtied 254716641
nr_written 254532248
nr_dirty_threshold 383652
nr_dirty_background_threshold 50612
pgpgin 21962903
pgpgout 1024651087
pswpin 214
pswpout 1127
pgalloc_dma 0
pgalloc_dma32 87690791
pgalloc_normal 806119097
pgalloc_movable 0
allocstall_dma 0
allocstall_dma32 0
allocstall_normal 210
allocstall_movable 0
pgskip_dma 0
pgskip_dma32 0
pgskip_normal 0
pgskip_movable 0
pgfree 894694404
pgactivate 5513535
pgdeactivate 7989719
pgfault 4748538
pgmajfault 2528
pglazyfreed 0
pgrefill 7999038
pgsteal_kswapd 504125672
pgsteal_direct 36130
pgscan_kswapd 504479233
pgscan_direct 36142
pgscan_direct_throttle 0
zone_reclaim_failed 0
pginodesteal 1074
slabs_scanned 61625344
kswapd_inodesteal 1956613
kswapd_low_wmark_hit_quickly 49386
kswapd_high_wmark_hit_quickly 79880
pageoutrun 211656
pgrotated 203832
drop_pagecache 0
drop_slab 0
pgmigrate_success 684523
pgmigrate_fail 1189249
compact_migrate_scanned 94848219
compact_free_scanned 2329620072
compact_isolated 2648057
compact_stall 38
compact_fail 0
compact_success 38
compact_daemon_wake 9682
htlb_buddy_alloc_success 0
htlb_buddy_alloc_fail 0
unevictable_pgs_culled 12473
unevictable_pgs_scanned 0
unevictable_pgs_rescued 11979
unevictable_pgs_mlocked 14556
unevictable_pgs_munlocked 14556
unevictable_pgs_cleared 0
unevictable_pgs_stranded 0
thp_fault_alloc 0
thp_fault_fallback 0
thp_collapse_alloc 0
thp_collapse_alloc_failed 0
thp_file_alloc 0
thp_file_mapped 0
thp_split_page 0
thp_split_page_failed 0
thp_deferred_split_page 0
thp_split_pmd 0
thp_zero_page_alloc 0
thp_zero_page_alloc_failed 0

On Thu, Nov 3, 2016 at 7:58 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 11/03/2016 07:53 PM, Andrew Morton wrote:
>>
>> (switched to email.  Please respond via emailed reply-to-all, not via the
>> bugzilla web interface).
>
> +CC also btrfs just in case it's a problem in page reclaim there
>
>> On Wed, 02 Nov 2016 13:02:39 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:
>>
>>> https://bugzilla.kernel.org/show_bug.cgi?id=186671
>>>
>>>             Bug ID: 186671
>>>            Summary: OOM on system with just rsync running 32GB of ram 30GB
>>>                     of pagecache
>>>            Product: Memory Management
>>>            Version: 2.5
>>>     Kernel Version: 4.9-rc3
>>>           Hardware: x86-64
>>>                 OS: Linux
>>>               Tree: Mainline
>>>             Status: NEW
>>>           Severity: high
>>>           Priority: P1
>>>          Component: Page Allocator
>>>           Assignee: akpm@linux-foundation.org
>>>           Reporter: eliventer@gmail.com
>>>         Regression: No
>>>
>>> Running rsync on a debian jessie system with 32GB of RAM and a big
>>> 250TB btrfs filesystem. 30 GB of ram show up as cached, not much else
>>> running on the system. Lots of page alloction stalls in dmesg before
>>> hand, and several OOM's after this one as well until it finally killed
>>> the rsync. So more traces available if desired. Started with the 4.7
>>> series kernels, thought it was going to be fixed in 4.9:
>>
>> OK, this looks bad.  Please let's work it via email so do remember the
>> reply-to-alls.
>
> It's bad but note the "started with 4.7" so it's not a 4.9 regression.
> Also not a high-order OOM (phew!).
>
>>> [93428.029768] irqbalance invoked oom-killer:
>>> gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=0-1, order=0,
>>> oom_score_adj=0
>>> [93428.029824] irqbalance cpuset=/ mems_allowed=0-1
>>> [93428.029857] CPU: 11 PID: 2992 Comm: irqbalance Tainted: G      W   4.9.0-rc3
>>> #1
>>> [93428.029945]  0000000000000000 ffffffff812946c9 ffffc90003d8bb10
>>> ffffc90003d8bb10
>>> [93428.029997]  ffffffff81190dd5 0000000000000000 0000000000000000
>>> ffff88081db051c0
>>> [93428.030049]  ffffc90003d8bb10 ffffffff81711866 0000000000000002
>>> 0000000000000213
>>> [93428.030101] Call Trace:
>>> [93428.030127]  [<ffffffff812946c9>] ? dump_stack+0x46/0x5d
>>> [93428.030157]  [<ffffffff81190dd5>] ? dump_header.isra.20+0x75/0x1a6
>>> [93428.030189]  [<ffffffff8112e589>] ? oom_kill_process+0x219/0x3d0
>>> [93428.030218]  [<ffffffff8112e999>] ? out_of_memory+0xd9/0x570
>>> [93428.030246]  [<ffffffff811339fb>] ? __alloc_pages_slowpath+0xa4b/0xa80
>>> [93428.030276]  [<ffffffff81133cb8>] ? __alloc_pages_nodemask+0x288/0x2c0
>>> [93428.030306]  [<ffffffff8117a4c1>] ? alloc_pages_vma+0xc1/0x240
>>> [93428.030337]  [<ffffffff8115ba2b>] ? handle_mm_fault+0xccb/0xe60
>>> [93428.030367]  [<ffffffff8104a245>] ? __do_page_fault+0x1c5/0x490
>>> [93428.030397]  [<ffffffff81506e22>] ? page_fault+0x22/0x30
>>> [93428.030425]  [<ffffffff812a090c>] ? copy_user_generic_string+0x2c/0x40
>>> [93428.030455]  [<ffffffff811b7095>] ? seq_read+0x305/0x370
>>> [93428.030483]  [<ffffffff811f48ee>] ? proc_reg_read+0x3e/0x60
>>> [93428.030511]  [<ffffffff81193abe>] ? __vfs_read+0x1e/0x110
>>> [93428.030538]  [<ffffffff811941d9>] ? vfs_read+0x89/0x130
>>> [93428.030564]  [<ffffffff811954fd>] ? SyS_read+0x3d/0x90
>>> [93428.030591]  [<ffffffff815051a0>] ? entry_SYSCALL_64_fastpath+0x13/0x94
>>> [93428.030620] Mem-Info:
>>> [93428.030647] active_anon:9283 inactive_anon:9905 isolated_anon:0
>>> [93428.030647]  active_file:6752598 inactive_file:999166 isolated_file:288
>>> [93428.030647]  unevictable:0 dirty:997857 writeback:1665 unstable:0
>>> [93428.030647]  slab_reclaimable:203122 slab_unreclaimable:202102
>>> [93428.030647]  mapped:7933 shmem:3170 pagetables:1752 bounce:0
>>> [93428.030647]  free:39250 free_pcp:954 free_cma:0
>>> [93428.030800] Node 0 active_anon:24984kB inactive_anon:26704kB
>>> active_file:14365920kB inactive_file:1341120kB unevictable:0kB
>>> isolated(anon):0kB isolated(file):0kB mapped:15852kB dirty:1338044kB
>>> writeback:3072kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB
>>> anon_thp: 9484kB writeback_tmp:0kB unstable:0kB pages_scanned:23811175
>>> all_unreclaimable? yes
>>> [93428.030933] Node 1 active_anon:12148kB inactive_anon:12916kB
>>> active_file:12644472kB inactive_file:2655544kB unevictable:0kB
>>> isolated(anon):0kB isolated(file):1152kB mapped:15880kB
>>> dirty:2653384kB writeback:3588kB shmem:0kB shmem_thp: 0kB
>>> shmem_pmdmapped: 0kB anon_thp: 3196kB writeback_tmp:0kB unstable:0kB
>>> pages_scanned:23178917 all_unreclaimable? yes
>
> Note the high pages_scanned and all_unreclaimable. I suspect something
> is pinning the memory. Can you post /proc/vmstat from the system with an
> uptime after it experiences the OOM?
>
> There's /proc/kpagecount file that could confirm that. Could you provide
> it too? Try running something like this and provide the output please.
>
> xxd -e -g8 -c8 /proc/kpagecount | cut -d" " -f2 | sort | uniq -c
>
>>> [93428.031059] Node 0 Normal free:44968kB min:45192kB low:61736kB
>>> high:78280kB active_anon:24984kB inactive_anon:26704kB
>>> active_file:14365920kB inactive_file:1341120kB unevictable:0kB
>>> writepending:1341116kB present:16777216kB managed:16546296kB
>>> mlocked:0kB slab_reclaimable:413824kB slab_unreclaimable:253144kB
>>> kernel_stack:3496kB pagetables:4104kB bounce:0kB free_pcp:1388kB
>>> local_pcp:0kB free_cma:0kB
>>> [93428.031211] lowmem_reserve[]: 0 0 0 0
>>> [93428.031245] Node 1 DMA free:15896kB min:40kB low:52kB high:64kB
>>> active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB
>>> unevictable:0kB writepending:0kB present:15996kB managed:15896kB
>>> mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB
>>> kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB
>>> free_cma:0kB
>>> [93428.031373] lowmem_reserve[]: 0 3216 16045 16045
>>> [93428.031408] Node 1 DMA32 free:60288kB min:8996kB low:12288kB
>>> high:15580kB active_anon:1360kB inactive_anon:1692kB
>>> active_file:2735200kB inactive_file:427992kB unevictable:0kB
>>> writepending:426716kB present:3378660kB managed:3304640kB mlocked:0kB
>>> slab_reclaimable:55012kB slab_unreclaimable:17160kB kernel_stack:176kB
>>> pagetables:132kB bounce:0kB free_pcp:120kB local_pcp:0kB free_cma:0kB
>>> [93428.031544] lowmem_reserve[]: 0 0 12828 12828
>>> [93428.031579] Node 1 Normal free:35848kB min:35880kB low:49016kB
>>> high:62152kB active_anon:10788kB inactive_anon:11224kB
>>> active_file:9909272kB inactive_file:2227552kB unevictable:0kB
>>> writepending:2230256kB present:13369344kB managed:13136800kB
>>> mlocked:0kB slab_reclaimable:343652kB slab_unreclaimable:538104kB
>>> kernel_stack:3112kB pagetables:2772kB bounce:0kB free_pcp:2308kB
>>> local_pcp:148kB free_cma:0kB
>>> [93428.031730] lowmem_reserve[]: 0 0 0 0
>>> [93428.031764] Node 0 Normal: 11132*4kB (UMH) 31*8kB (H) 12*16kB (H)
>>> 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =
>>> 44968kB
>>> [93428.031853] Node 1 DMA: 0*4kB 1*8kB (U) 1*16kB (U) 0*32kB 2*64kB
>>> (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB
>>> (M) = 15896kB
>>> [93428.031956] Node 1 DMA32: 14990*4kB (UME) 41*8kB (UM) 0*16kB 0*32kB
>>> 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 60288kB
>>> [93428.032043] Node 1 Normal: 8958*4kB (M) 2*8kB (M) 0*16kB 0*32kB
>>> 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 35848kB
>>> [93428.032130] Node 0 hugepages_total=0 hugepages_free=0
>>> hugepages_surp=0 hugepages_size=1048576kB
>>> [93428.032176] Node 0 hugepages_total=0 hugepages_free=0
>>> hugepages_surp=0 hugepages_size=2048kB
>>> [93428.032222] Node 1 hugepages_total=0 hugepages_free=0
>>> hugepages_surp=0 hugepages_size=1048576kB
>>> [93428.032267] Node 1 hugepages_total=0 hugepages_free=0
>>> hugepages_surp=0 hugepages_size=2048kB
>>> [93428.032313] 7758107 total pagecache pages
>>> [93428.032336] 2885 pages in swap cache
>>> [93428.032360] Swap cache stats: add 609178, delete 606293, find 331548/559119
>>> [93428.032388] Free swap  = 48055104kB
>>> [93428.032411] Total swap = 48300028kB
>>> [93428.032434] 8385304 pages RAM
>>> [93428.032455] 0 pages HighMem/MovableOnly
>>> [93428.032478] 134396 pages reserved
>>> [93428.032500] 0 pages hwpoisoned
>>> [93428.032522] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds
>>> swapents oom_score_adj name
>>> [93428.032573] [ 1912]     0  1912    10572     1903      27       3
>>>     58             0 systemd-journal
>>> [93428.032622] [ 1915]     0  1915     9953      482      22       4
>>>    304         -1000 systemd-udevd
>>> [93428.032670] [ 2813]     0  2813     9270      432      24       3
>>>    114             0 rpcbind
>>> [93428.032717] [ 2832]   102  2832     9320      438      23       3
>>>    150             0 rpc.statd
>>> [93428.032765] [ 2848]     0  2848     5839      282      16       3
>>>     75             0 rpc.idmapd
>>> [93428.032812] [ 2851]   104  2851    88525     1167      44       3
>>>   2225             0 apt-cacher-ng
>>> [93428.032860] [ 2852]     0  2852    13796      754      32       3
>>>    168         -1000 sshd
>>> [93428.032906] [ 2853]     0  2853    64668      751      28       3
>>>    153             0 rsyslogd
>>> [93428.032954] [ 2854]     0  2854     6876      473      17       3
>>>     62             0 cron
>>> [93428.033000] [ 2855]     0  2855     4756      389      15       3
>>>     45             0 atd
>>> [93428.033046] [ 2856]     0  2856     7059      520      19       3
>>>    592             0 smartd
>>> [93428.033093] [ 2860]     0  2860     7089      554      19       3
>>>     96             0 systemd-logind
>>> [93428.033141] [ 2861]   106  2861    10531      549      26       3
>>>    102          -900 dbus-daemon
>>> [93428.033194] [ 2990]   107  2990     7293      729      19       3
>>>    150             0 ntpd
>>> [93428.033241] [ 2992]     0  2992     4853      417      16       3
>>>     31             0 irqbalance
>>> [93428.033289] [ 3013]     0  3013    26571      387      43       3
>>>    258             0 sfcbd
>>> [93428.033336] [ 3017]     0  3017    20392      270      40       3
>>>    235             0 sfcbd
>>> [93428.033383] [ 3020]     0  3020     3180      229       9       3
>>>     39             0 mcelog
>>> [93428.033429] [ 3050]     0  3050    22441        0      41       3
>>>    237             0 sfcbd
>>> [93428.033476] [ 3051]     0  3051    57809      318      45       3
>>>    379             0 sfcbd
>>> [93428.033523] [ 3371]   105  3371    18063      770      36       3
>>>   5046             0 snmpd
>>> [93428.033569] [ 3473]     0  3473    39377      263      44       3
>>>    243             0 sfcbd
>>> [93428.033616] [ 3479]     0  3479    58324      448      46       3
>>>    283             0 sfcbd
>>> [93428.033663] [ 3561]     0  3561   262687      975      65       4
>>>   3828             0 dsm_sa_datamgrd
>>> [93428.033711] [ 3565]   101  3565    13312      606      29       3
>>>    184             0 exim4
>>> [93428.033758] [ 3580]     0  3580    61531     1209     115       3
>>>    467             0 winbindd
>>> [93428.033805] [ 3581]     0  3581    61531     1226     118       3
>>>    433             0 winbindd
>>> [93428.033852] [ 3647]     0  3647    48584      826      37       4
>>>    260             0 dsm_sa_eventmgr
>>> [93428.033900] [ 3670]     0  3670    99593      919      47       3
>>>   1346             0 dsm_sa_snmpd
>>> [93428.033948] [ 3713]     0  3713     7923      307      16       3
>>>    116             0 dsm_om_connsvcd
>>> [93428.033996] [ 3714]     0  3714   961001    15661     261       8
>>>  33671             0 dsm_om_connsvcd
>>> [93428.036621] [ 3719]     0  3719   178651        0      57       4
>>>   3787             0 dsm_sa_datamgrd
>>> [93428.036669] [ 3825]     0  3825     3604      403      12       3
>>>     38             0 agetty
>>> [93428.036716] [ 3977]     0  3977    26472      831      54       3
>>>    252             0 sshd
>>> [93428.036762] [ 3979]  1000  3979     8941      665      23       3
>>>    182             0 systemd
>>> [93428.036809] [ 3980]  1000  3980    15684        0      34       3
>>>    542             0 (sd-pam)
>>> [93428.036857] [ 3982]  1000  3982    26472      637      52       3
>>>    239             0 sshd
>>> [93428.036903] [ 3983]  1000  3983     6041      701      16       3
>>>    686             0 bash
>>> [93428.036950] [ 3998]  1000  3998    16853      517      37       3
>>>    127             0 su
>>> [93428.036996] [ 3999]     0  3999     5483      820      15       3
>>>     65             0 bash
>>> [93428.037043] [ 4534]     0  4534     3311      584      11       3
>>>     58             0 run_mirror.sh
>>> [93428.037091] [14179]     0 14179     1450       49       8       3
>>>     23             0 flock
>>> [93428.037137] [14180]     0 14180     9289     1293      23       3
>>>   3217             0 rsync
>>> [93428.037188] [14181]     0 14181     7616      584      20       3
>>>    821             0 rsync
>>> [93428.037237] [14182]     0 14182     9171      598      23       3
>>>   2352             0 rsync
>>> [93428.037287] [15616]     0 15616     2050      535       9       3
>>>      0             0 less
>>> [93428.037332] Out of memory: Kill process 3714 (dsm_om_connsvcd)
>>> score 2 or sacrifice child
>>> [93428.037455] Killed process 3714 (dsm_om_connsvcd)
>>> total-vm:3844004kB, anon-rss:49616kB, file-rss:13028kB, shmem-rss:0kB
>>> [93428.068402] oom_reaper: reaped process 3714 (dsm_om_connsvcd), now
>>> anon-rss:0kB, file-rss:20kB, shmem-rss:0kB
>>>
>>> --
>>> You are receiving this mail because:
>>> You are the assignee for the bug.
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
