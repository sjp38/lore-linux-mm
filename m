Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0D6D96B0388
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 06:03:24 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id t143so82241592pgb.5
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 03:03:24 -0700 (PDT)
Received: from shells.gnugeneration.com (shells.gnugeneration.com. [66.240.222.126])
        by mx.google.com with ESMTP id 201si3402281pfy.279.2017.03.16.03.03.23
        for <linux-mm@kvack.org>;
        Thu, 16 Mar 2017 03:03:23 -0700 (PDT)
Date: Thu, 16 Mar 2017 03:04:09 -0700
From: "Philip J. Freeman" <elektron@halo.nu>
Subject: DOM Worker: page allocation stalls (4.9.13)
Message-ID: <20170316100409.GR802@shells.gnugeneration.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="wxDdMuZNg1r63Hyj"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org


--wxDdMuZNg1r63Hyj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

My laptop became almost totally un responsive today. I was able to
switch VTs but not log in and had to power cycle to regain control. I
don't understand what this means. Any ideas?


-- 
"Philip Freeman" <elektron@halo.nu>

--wxDdMuZNg1r63Hyj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="kernel-log.txt"

Mar 14 14:31:20 x61s-44a5 kernel: [168382.032039] DOM Worker: page allocation stalls for 10646ms, order:0, mode:0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO)
Mar 14 14:31:22 x61s-44a5 kernel: [168382.032061] CPU: 0 PID: 30909 Comm: DOM Worker Not tainted 4.9.13 #5
Mar 14 14:31:22 x61s-44a5 kernel: [168382.032065] Hardware name: LENOVO 7667WAL/7667WAL, BIOS 7NETC2WW (2.22 ) 03/22/2011
Mar 14 14:31:22 x61s-44a5 kernel: [168382.032069]  0000000000000000 ffffffff8143375d ffffffff81c2dbb0 ffffc90003fdbce8
Mar 14 14:31:22 x61s-44a5 kernel: [168382.032080]  ffffffff811adc58 024280caffffffff ffffffff81c2dbb0 ffffc90003fdbc88
Mar 14 14:31:22 x61s-44a5 kernel: [168382.032090]  0000000100000010 ffffc90003fdbcf8 ffffc90003fdbca8 000000001b5962f9
Mar 14 14:31:22 x61s-44a5 kernel: [168382.032100] Call Trace:
Mar 14 14:31:22 x61s-44a5 kernel: [168382.032115]  [<ffffffff8143375d>] ? dump_stack+0x46/0x59
Mar 14 14:31:22 x61s-44a5 kernel: [168382.032124]  [<ffffffff811adc58>] ? warn_alloc+0x148/0x170
Mar 14 14:31:22 x61s-44a5 kernel: [168382.032131]  [<ffffffff811ae5ea>] ? __alloc_pages_slowpath+0x8ea/0xb80
Mar 14 14:31:22 x61s-44a5 kernel: [168382.032138]  [<ffffffff811d91f5>] ? alloc_set_pte+0x1c5/0x460
Mar 14 14:31:22 x61s-44a5 kernel: [168382.032144]  [<ffffffff811aeac1>] ? __alloc_pages_nodemask+0x221/0x270
Mar 14 14:31:22 x61s-44a5 kernel: [168382.032149]  [<ffffffff811dae2b>] ? handle_mm_fault+0xe5b/0x1030
Mar 14 14:31:22 x61s-44a5 kernel: [168382.032157]  [<ffffffff819e81a3>] ? _raw_spin_unlock_irq+0x13/0x30
Mar 14 14:31:22 x61s-44a5 kernel: [168382.032164]  [<ffffffff810e7d3f>] ? finish_task_switch+0x7f/0x220
Mar 14 14:31:22 x61s-44a5 kernel: [168382.032171]  [<ffffffff81091766>] ? __do_page_fault+0x206/0x420
Mar 14 14:31:22 x61s-44a5 kernel: [168382.032177]  [<ffffffff819e961f>] ? page_fault+0x1f/0x30
Mar 14 14:31:22 x61s-44a5 kernel: [168382.032181] Mem-Info:
Mar 14 14:31:22 x61s-44a5 kernel: [168382.032192] active_anon:308454 inactive_anon:154809 isolated_anon:224
Mar 14 14:31:22 x61s-44a5 kernel: [168382.032192]  active_file:869 inactive_file:978 isolated_file:0
Mar 14 14:31:22 x61s-44a5 kernel: [168382.032192]  unevictable:0 dirty:0 writeback:0 unstable:0
Mar 14 14:31:22 x61s-44a5 kernel: [168382.032192]  slab_reclaimable:6099 slab_unreclaimable:8555
Mar 14 14:31:22 x61s-44a5 kernel: [168382.032192]  mapped:1999 shmem:156254 pagetables:2929 bounce:0
Mar 14 14:31:22 x61s-44a5 kernel: [168382.032192]  free:13192 free_pcp:0 free_cma:0
Mar 14 14:31:22 x61s-44a5 kernel: [168382.032203] Node 0 active_anon:1233816kB inactive_anon:619320kB active_file:3476kB inactive_file:3912kB unevictable:0kB isolated(anon):768kB isolated(file):0kB mapped:7996kB dirty:0kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 625016kB writeback_tmp:0kB unstable:0kB pages_scanned:80297 all_unreclaimable? no
Mar 14 14:31:22 x61s-44a5 kernel: [168382.032215] DMA free:8084kB min:356kB low:444kB high:532kB active_anon:6284kB inactive_anon:1312kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15984kB managed:15900kB mlocked:0kB slab_reclaimable:44kB slab_unreclaimable:44kB kernel_stack:0kB pagetables:56kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
Mar 14 14:31:22 x61s-44a5 kernel: lowmem_reserve[]: 0 1933 1933 1933
Mar 14 14:31:22 x61s-44a5 kernel: [168382.032237] DMA32 free:44684kB min:44696kB low:55868kB high:67040kB active_anon:1227532kB inactive_anon:618004kB active_file:3476kB inactive_file:3912kB unevictable:0kB writepending:0kB present:2038464kB managed:1986592kB mlocked:0kB slab_reclaimable:24352kB slab_unreclaimable:34176kB kernel_stack:4016kB pagetables:11660kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
Mar 14 14:31:22 x61s-44a5 kernel: lowmem_reserve[]: 0 0 0 0
Mar 14 14:31:22 x61s-44a5 kernel: [168382.032250] DMA: 25*4kB (UME) 10*8kB (E) 8*16kB (UME) 5*32kB (UME) 5*64kB (UME) 5*128kB (UE) 4*256kB (UME) 3*512kB (UME) 2*1024kB (ME) 1*2048kB (M) 0*4096kB = 8084kB
Mar 14 14:31:22 x61s-44a5 kernel: DMA32: 1208*4kB (UME) 856*8kB (UME) 779*16kB (UME) 295*32kB (UME) 106*64kB (UME) 20*128kB (UME) 7*256kB (ME) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 44720kB
Mar 14 14:31:22 x61s-44a5 kernel: [168382.032340] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
Mar 14 14:31:22 x61s-44a5 kernel: [168382.032343] 159096 total pagecache pages
Mar 14 14:31:22 x61s-44a5 kernel: [168382.032348] 955 pages in swap cache
Mar 14 14:31:22 x61s-44a5 kernel: [168382.032352] Swap cache stats: add 267105, delete 266150, find 100036/132538
Mar 14 14:31:22 x61s-44a5 kernel: [168382.032355] Free swap  = 1836400kB
Mar 14 14:31:22 x61s-44a5 kernel: [168382.032358] Total swap = 1949692kB
Mar 14 14:31:22 x61s-44a5 kernel: [168382.032360] 513612 pages RAM
Mar 14 14:31:22 x61s-44a5 kernel: [168382.032363] 0 pages HighMem/MovableOnly
Mar 14 14:31:22 x61s-44a5 kernel: [168382.032365] 12989 pages reserved
Mar 14 14:35:41 x61s-44a5 kernel: [168644.685090] DOM Worker: page allocation stalls for 11024ms, order:0, mode:0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO)
Mar 14 14:35:42 x61s-44a5 kernel: [168644.685113] CPU: 0 PID: 30909 Comm: DOM Worker Not tainted 4.9.13 #5
Mar 14 14:35:42 x61s-44a5 kernel: [168644.685117] Hardware name: LENOVO 7667WAL/7667WAL, BIOS 7NETC2WW (2.22 ) 03/22/2011
Mar 14 14:35:42 x61s-44a5 kernel: [168644.685121]  0000000000000000 ffffffff8143375d ffffffff81c2dbb0 ffffc90003fdbce8
Mar 14 14:35:42 x61s-44a5 kernel: [168644.685132]  ffffffff811adc58 024280caffffffff ffffffff81c2dbb0 ffffc90003fdbc88
Mar 14 14:35:42 x61s-44a5 kernel: [168644.685142]  0000000000000010 ffffc90003fdbcf8 ffffc90003fdbca8 000000001b5962f9
Mar 14 14:35:42 x61s-44a5 kernel: [168644.685152] Call Trace:
Mar 14 14:35:42 x61s-44a5 kernel: [168644.685168]  [<ffffffff8143375d>] ? dump_stack+0x46/0x59
Mar 14 14:35:42 x61s-44a5 kernel: [168644.685177]  [<ffffffff811adc58>] ? warn_alloc+0x148/0x170
Mar 14 14:35:42 x61s-44a5 kernel: [168644.685183]  [<ffffffff811ae5ea>] ? __alloc_pages_slowpath+0x8ea/0xb80
Mar 14 14:35:42 x61s-44a5 kernel: [168644.685190]  [<ffffffff81107370>] ? cpuacct_charge+0x50/0x80
Mar 14 14:35:42 x61s-44a5 kernel: [168644.685196]  [<ffffffff810f5b7a>] ? update_curr+0xba/0x150
Mar 14 14:35:42 x61s-44a5 kernel: [168644.685202]  [<ffffffff811aeac1>] ? __alloc_pages_nodemask+0x221/0x270
Mar 14 14:35:42 x61s-44a5 kernel: [168644.685209]  [<ffffffff811dae2b>] ? handle_mm_fault+0xe5b/0x1030
Mar 14 14:35:42 x61s-44a5 kernel: [168644.685217]  [<ffffffff819e81a3>] ? _raw_spin_unlock_irq+0x13/0x30
Mar 14 14:35:42 x61s-44a5 kernel: [168644.685222]  [<ffffffff810e7d3f>] ? finish_task_switch+0x7f/0x220
Mar 14 14:35:42 x61s-44a5 kernel: [168644.685229]  [<ffffffff81091766>] ? __do_page_fault+0x206/0x420
Mar 14 14:35:42 x61s-44a5 kernel: [168644.685236]  [<ffffffff819e961f>] ? page_fault+0x1f/0x30
Mar 14 14:35:42 x61s-44a5 kernel: [168644.685239] Mem-Info:
Mar 14 14:35:42 x61s-44a5 kernel: [168644.685251] active_anon:308078 inactive_anon:154761 isolated_anon:256
Mar 14 14:35:42 x61s-44a5 kernel: [168644.685251]  active_file:1046 inactive_file:1061 isolated_file:0
Mar 14 14:35:42 x61s-44a5 kernel: [168644.685251]  unevictable:0 dirty:0 writeback:0 unstable:0
Mar 14 14:35:42 x61s-44a5 kernel: [168644.685251]  slab_reclaimable:6098 slab_unreclaimable:8554
Mar 14 14:35:42 x61s-44a5 kernel: [168644.685251]  mapped:2252 shmem:156234 pagetables:2929 bounce:0
Mar 14 14:35:42 x61s-44a5 kernel: [168644.685251]  free:13191 free_pcp:116 free_cma:0
Mar 14 14:35:42 x61s-44a5 kernel: [168644.685262] Node 0 active_anon:1232312kB inactive_anon:618960kB active_file:4184kB inactive_file:4244kB unevictable:0kB isolated(anon):1152kB isolated(file):0kB mapped:9008kB dirty:0kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 624936kB writeback_tmp:0kB unstable:0kB pages_scanned:373767 all_unreclaimable? no
Mar 14 14:35:42 x61s-44a5 kernel: [168644.685273] DMA free:8084kB min:356kB low:444kB high:532kB active_anon:6284kB inactive_anon:1312kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15984kB managed:15900kB mlocked:0kB slab_reclaimable:44kB slab_unreclaimable:44kB kernel_stack:0kB pagetables:56kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
Mar 14 14:35:42 x61s-44a5 kernel: lowmem_reserve[]: 0 1933 1933 1933
Mar 14 14:35:42 x61s-44a5 kernel: [168644.685296] DMA32 free:44680kB min:44696kB low:55868kB high:67040kB active_anon:1226028kB inactive_anon:617640kB active_file:4184kB inactive_file:4244kB unevictable:0kB writepending:0kB present:2038464kB managed:1986592kB mlocked:0kB slab_reclaimable:24348kB slab_unreclaimable:34172kB kernel_stack:4048kB pagetables:11660kB bounce:0kB free_pcp:464kB local_pcp:332kB free_cma:0kB
Mar 14 14:35:42 x61s-44a5 kernel: lowmem_reserve[]: 0 0 0 0
Mar 14 14:35:42 x61s-44a5 kernel: [168644.685308] DMA: 25*4kB (UME) 10*8kB (E) 8*16kB (UME) 5*32kB (UME) 5*64kB (UME) 5*128kB (UE) 4*256kB (UME) 3*512kB (UME) 2*1024kB (ME) 1*2048kB (M) 0*4096kB = 8084kB
Mar 14 14:35:42 x61s-44a5 kernel: DMA32: 1170*4kB (UME) 873*8kB (UME) 786*16kB (UME) 293*32kB (UME) 106*64kB (UME) 20*128kB (UME) 7*256kB (ME) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 44752kB
Mar 14 14:35:42 x61s-44a5 kernel: [168644.685393] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
Mar 14 14:35:42 x61s-44a5 kernel: [168644.685396] 159390 total pagecache pages
Mar 14 14:35:42 x61s-44a5 kernel: [168644.685401] 955 pages in swap cache
Mar 14 14:35:42 x61s-44a5 kernel: [168644.685405] Swap cache stats: add 268249, delete 267294, find 100354/133093
Mar 14 14:35:42 x61s-44a5 kernel: [168644.685407] Free swap  = 1836464kB
Mar 14 14:35:42 x61s-44a5 kernel: [168644.685410] Total swap = 1949692kB
Mar 14 14:35:42 x61s-44a5 kernel: [168644.685413] 513612 pages RAM
Mar 14 14:35:42 x61s-44a5 kernel: [168644.685415] 0 pages HighMem/MovableOnly
Mar 14 14:35:42 x61s-44a5 kernel: [168644.685417] 12989 pages reserved
Mar 14 14:37:32 x61s-44a5 kernel: [168756.031364] firefox-esr: page allocation stalls for 12753ms, order:0, mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031387] CPU: 0 PID: 22792 Comm: firefox-esr Not tainted 4.9.13 #5
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031391] Hardware name: LENOVO 7667WAL/7667WAL, BIOS 7NETC2WW (2.22 ) 03/22/2011
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031396]  0000000000000000 ffffffff8143375d ffffffff81c2dbb0 ffffc90001b3fc10
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031407]  ffffffff811adc58 024201caffffffff ffffffff81c2dbb0 ffffc90001b3fbb0
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031417]  ffffffff00000010 ffffc90001b3fc20 ffffc90001b3fbd0 00000000a39f40ac
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031427] Call Trace:
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031443]  [<ffffffff8143375d>] ? dump_stack+0x46/0x59
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031452]  [<ffffffff811adc58>] ? warn_alloc+0x148/0x170
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031458]  [<ffffffff811abda0>] ? drain_pages+0x20/0x60
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031465]  [<ffffffff811ae5ea>] ? __alloc_pages_slowpath+0x8ea/0xb80
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031472]  [<ffffffff8140d485>] ? blk_finish_plug+0x25/0x40
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031477]  [<ffffffff811b3fe0>] ? __do_page_cache_readahead+0x1e0/0x290
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031484]  [<ffffffff811febf1>] ? ___cache_free+0x31/0x1c0
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031491]  [<ffffffff814381d6>] ? __radix_tree_lookup+0x76/0xe0
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031497]  [<ffffffff811aeac1>] ? __alloc_pages_nodemask+0x221/0x270
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031502]  [<ffffffff811a6d2a>] ? filemap_fault+0x30a/0x4e0
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031510]  [<ffffffff812af6c1>] ? ext4_filemap_fault+0x31/0x50
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031516]  [<ffffffff811d6602>] ? __do_fault+0x82/0x100
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031522]  [<ffffffff811dab9a>] ? handle_mm_fault+0xbca/0x1030
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031529]  [<ffffffff81091766>] ? __do_page_fault+0x206/0x420
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031537]  [<ffffffff819e961f>] ? page_fault+0x1f/0x30
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031540] Mem-Info:
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031552] active_anon:308635 inactive_anon:154041 isolated_anon:224
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031552]  active_file:1195 inactive_file:1218 isolated_file:0
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031552]  unevictable:0 dirty:0 writeback:0 unstable:0
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031552]  slab_reclaimable:6095 slab_unreclaimable:8550
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031552]  mapped:2380 shmem:155496 pagetables:2929 bounce:0
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031552]  free:13192 free_pcp:0 free_cma:0
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031562] Node 0 active_anon:1234540kB inactive_anon:616080kB active_file:4780kB inactive_file:4872kB unevictable:0kB isolated(anon):1024kB isolated(file):0kB mapped:9520kB dirty:0kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 621984kB writeback_tmp:0kB unstable:0kB pages_scanned:192 all_unreclaimable? no
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031574] DMA free:8084kB min:356kB low:444kB high:532kB active_anon:6284kB inactive_anon:1312kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15984kB managed:15900kB mlocked:0kB slab_reclaimable:44kB slab_unreclaimable:44kB kernel_stack:0kB pagetables:56kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
Mar 14 14:37:34 x61s-44a5 kernel: lowmem_reserve[]: 0 1933 1933 1933
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031597] DMA32 free:44684kB min:44696kB low:55868kB high:67040kB active_anon:1228256kB inactive_anon:614844kB active_file:4780kB inactive_file:4872kB unevictable:0kB writepending:0kB present:2038464kB managed:1986592kB mlocked:0kB slab_reclaimable:24336kB slab_unreclaimable:34156kB kernel_stack:4048kB pagetables:11660kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
Mar 14 14:37:34 x61s-44a5 kernel: lowmem_reserve[]: 0 0 0 0
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031609] DMA: 25*4kB (UME) 10*8kB (E) 8*16kB (UME) 5*32kB (UME) 5*64kB (UME) 5*128kB (UE) 4*256kB (UME) 3*512kB (UME) 2*1024kB (ME) 1*2048kB (M) 0*4096kB = 8084kB
Mar 14 14:37:34 x61s-44a5 kernel: DMA32: 933*4kB (UME) 1000*8kB (UME) 784*16kB (UME) 293*32kB (UME) 106*64kB (UME) 20*128kB (UME) 7*256kB (ME) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 44788kB
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031698] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031701] 158882 total pagecache pages
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031706] 955 pages in swap cache
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031710] Swap cache stats: add 268818, delete 267863, find 100476/133379
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031713] Free swap  = 1836440kB
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031716] Total swap = 1949692kB
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031718] 513612 pages RAM
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031721] 0 pages HighMem/MovableOnly
Mar 14 14:37:34 x61s-44a5 kernel: [168756.031723] 12989 pages reserved
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164143] DOM Worker: page allocation stalls for 14239ms, order:0, mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164167] CPU: 1 PID: 23292 Comm: DOM Worker Not tainted 4.9.13 #5
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164171] Hardware name: LENOVO 7667WAL/7667WAL, BIOS 7NETC2WW (2.22 ) 03/22/2011
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164176]  0000000000000000 ffffffff8143375d ffffffff81c2dbb0 ffffc900037dfc10
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164187]  ffffffff811adc58 024201caffffffff ffffffff81c2dbb0 ffffc900037dfbb0
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164197]  0000000000000010 ffffc900037dfc20 ffffc900037dfbd0 000000004cc44952
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164207] Call Trace:
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164222]  [<ffffffff8143375d>] ? dump_stack+0x46/0x59
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164231]  [<ffffffff811adc58>] ? warn_alloc+0x148/0x170
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164237]  [<ffffffff811ae5ea>] ? __alloc_pages_slowpath+0x8ea/0xb80
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164244]  [<ffffffff811b3f0f>] ? __do_page_cache_readahead+0x10f/0x290
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164250]  [<ffffffff814381d6>] ? __radix_tree_lookup+0x76/0xe0
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164256]  [<ffffffff811aeac1>] ? __alloc_pages_nodemask+0x221/0x270
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164262]  [<ffffffff811a6d2a>] ? filemap_fault+0x30a/0x4e0
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164270]  [<ffffffff812af6c1>] ? ext4_filemap_fault+0x31/0x50
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164276]  [<ffffffff811d6602>] ? __do_fault+0x82/0x100
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164282]  [<ffffffff811dab9a>] ? handle_mm_fault+0xbca/0x1030
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164289]  [<ffffffff81091766>] ? __do_page_fault+0x206/0x420
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164297]  [<ffffffff819e961f>] ? page_fault+0x1f/0x30
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164300] Mem-Info:
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164313] active_anon:308681 inactive_anon:154714 isolated_anon:320
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164313]  active_file:759 inactive_file:749 isolated_file:0
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164313]  unevictable:0 dirty:0 writeback:0 unstable:0
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164313]  slab_reclaimable:6095 slab_unreclaimable:8550
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164313]  mapped:1762 shmem:156270 pagetables:2929 bounce:0
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164313]  free:13193 free_pcp:93 free_cma:0
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164324] Node 0 active_anon:1234724kB inactive_anon:618940kB active_file:3036kB inactive_file:2996kB unevictable:0kB isolated(anon):1152kB isolated(file):0kB mapped:7048kB dirty:0kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 625080kB writeback_tmp:0kB unstable:0kB pages_scanned:106721 all_unreclaimable? no
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164335] DMA free:8084kB min:356kB low:444kB high:532kB active_anon:6284kB inactive_anon:1316kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15984kB managed:15900kB mlocked:0kB slab_reclaimable:44kB slab_unreclaimable:44kB kernel_stack:0kB pagetables:56kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
Mar 14 14:38:52 x61s-44a5 kernel: lowmem_reserve[]: 0 1933 1933 1933
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164357] DMA32 free:44688kB min:44696kB low:55868kB high:67040kB active_anon:1228440kB inactive_anon:617620kB active_file:3036kB inactive_file:2996kB unevictable:0kB writepending:0kB present:2038464kB managed:1986592kB mlocked:0kB slab_reclaimable:24336kB slab_unreclaimable:34156kB kernel_stack:4048kB pagetables:11660kB bounce:0kB free_pcp:372kB local_pcp:240kB free_cma:0kB
Mar 14 14:38:52 x61s-44a5 kernel: lowmem_reserve[]: 0 0 0 0
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164370] DMA: 25*4kB (UME) 10*8kB (E) 8*16kB (UME) 5*32kB (UME) 5*64kB (UME) 5*128kB (UE) 4*256kB (UME) 3*512kB (UME) 2*1024kB (ME) 1*2048kB (M) 0*4096kB = 8084kB
Mar 14 14:38:52 x61s-44a5 kernel: DMA32: 1075*4kB (UME) 904*8kB (UME) 795*16kB (UME) 291*32kB (UME) 106*64kB (UME) 20*128kB (UME) 7*256kB (ME) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 44700kB
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164461] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164463] 158783 total pagecache pages
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164468] 955 pages in swap cache
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164472] Swap cache stats: add 268937, delete 267982, find 100496/133435
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164475] Free swap  = 1836432kB
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164478] Total swap = 1949692kB
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164480] 513612 pages RAM
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164483] 0 pages HighMem/MovableOnly
Mar 14 14:38:52 x61s-44a5 kernel: [168835.164485] 12989 pages reserved

--wxDdMuZNg1r63Hyj--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
