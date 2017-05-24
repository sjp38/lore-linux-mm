Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4C8356B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 18:55:42 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r203so40125380wmb.2
        for <linux-mm@kvack.org>; Wed, 24 May 2017 15:55:42 -0700 (PDT)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id i24si22042111wra.8.2017.05.24.15.55.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 15:55:39 -0700 (PDT)
Received: by mail-wm0-x22f.google.com with SMTP id d127so81204438wmf.0
        for <linux-mm@kvack.org>; Wed, 24 May 2017 15:55:39 -0700 (PDT)
MIME-Version: 1.0
From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed, 24 May 2017 15:55:18 -0700
Message-ID: <CAM_iQpWuPVGc2ky8M-9yukECtS+zKjiDasNymX7rMcBjBFyM_A@mail.gmail.com>
Subject: Yet another page allocation stall on 4.9
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hello, mm experts


I know there are at least two similar reports of page allocation stall
on 4.9, but I am not sure if they all have the same cause nor I could
find any fix to the problem.

Below is the one we got when running LTP memcg_stress test with 150
memcg groups each with 0.5g memory on a 64G memory host. So far, this
is not reproducible at all.

Please let me know if I can provide any other information you need.

Thanks.

[16211.987039]  [<ffffffff86395ab7>] dump_stack+0x4d/0x66^M
[16211.997600]  [<ffffffff8619a6c6>] warn_alloc+0x116/0x130^M
[16212.017235]  [<ffffffff8619b0bf>] __alloc_pages_slowpath+0x96f/0xbd0^M
[16212.037413]  [<ffffffff8619b4f6>] __alloc_pages_nodemask+0x1d6/0x230^M
[16212.057215]  [<ffffffff861e61d5>] alloc_pages_current+0x95/0x140^M
[16212.077023]  [<ffffffff8619114a>] __page_cache_alloc+0xca/0xe0^M
[16212.087943]  [<ffffffff86194312>] filemap_fault+0x312/0x4d0^M
[16212.107591]  [<ffffffff862a8196>] ext4_filemap_fault+0x36/0x50^M
[16212.127232]  [<ffffffff861c2c71>] __do_fault+0x71/0x130^M
[16212.146862]  [<ffffffff861c6cec>] handle_mm_fault+0xebc/0x13a0^M
[16212.166836]  [<ffffffff860509e4>] __do_page_fault+0x254/0x4a0^M
[16212.177664]  [<ffffffff86050c50>] do_page_fault+0x20/0x70^M
[16212.197438]  [<ffffffff86700aa2>] page_fault+0x22/0x30^M
[16212.217026] CPU: 4 PID: 3872 Comm: scribed Not tainted
4.9.23.el7.twitter.x86_64 #1^M
[16212.217035] Mem-Info:^M
[16212.217041] active_anon:16069537 inactive_anon:5561 isolated_anon:0^M
[16212.217041]  active_file:1301 inactive_file:1449 isolated_file:0^M
[16212.217041]  unevictable:0 dirty:0 writeback:0 unstable:0^M
[16212.217041]  slab_reclaimable:22962 slab_unreclaimable:79806^M
[16212.217041]  mapped:6434 shmem:6365 pagetables:34668 bounce:0^M
[16212.217041]  free:161016 free_pcp:955 free_cma:0^M
[16212.217047] Node 0 active_anon:31718548kB inactive_anon:8728kB
active_file:4988kB inactive_file:5584kB unevictable:0kB
isolated(anon):0kB isolated(file):0kB mapped:11524kB dirty:0kB
writeback:0kB shmem:8832kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 0kB writeback_tmp:0kB unstable:0kB pages_scanned:0
all_unreclaimable? no^M
[16212.217051] Node 1 active_anon:32559600kB inactive_anon:13516kB
active_file:216kB inactive_file:212kB unevictable:0kB
isolated(anon):0kB isolated(file):0kB mapped:14208kB dirty:0kB
writeback:0kB shmem:16628kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 0kB writeback_tmp:0kB unstable:0kB pages_scanned:683486
all_unreclaimable? yes^M
[16212.217056] Node 0 DMA free:15888kB min:20kB low:32kB high:44kB
active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB
unevictable:0kB writepending:0kB present:15972kB managed:15888kB
mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB
kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB
free_cma:0kB^M
[16212.217058] lowmem_reserve[]: 0 1903 32095 32095^M
[16212.217062] Node 0 DMA32 free:123344kB min:2668kB low:4616kB
high:6564kB active_anon:1820276kB inactive_anon:0kB active_file:0kB
inactive_file:0kB unevictable:0kB writepending:0kB present:2015240kB
managed:1949672kB mlocked:0kB slab_reclaimable:64kB
slab_unreclaimable:2216kB kernel_stack:0kB pagetables:3544kB
bounce:0kB free_pcp:120kB local_pcp:0kB free_cma:0kB^M
[16212.217064] lowmem_reserve[]: 0 0 30191 30191^M
[16212.217068] Node 0 Normal free:460088kB min:42308kB low:73224kB
high:104140kB active_anon:29898272kB inactive_anon:8728kB
active_file:4988kB inactive_file:5584kB unevictable:0kB
writepending:0kB present:31457280kB managed:30916476kB mlocked:0kB
slab_reclaimable:52244kB slab_unreclaimable:172728kB
kernel_stack:5976kB pagetables:64740kB bounce:0kB free_pcp:2588kB
local_pcp:120kB free_cma:0kB^M
[16212.217070] lowmem_reserve[]: 0 0 0 0^M
[16212.217074] Node 1 Normal free:44744kB min:45108kB low:78068kB
high:111028kB active_anon:32559600kB inactive_anon:13516kB
active_file:216kB inactive_file:212kB unevictable:0kB writepending:0kB
present:33554432kB managed:32962516kB mlocked:0kB
slab_reclaimable:39540kB slab_unreclaimable:144280kB
kernel_stack:5208kB pagetables:70388kB bounce:0kB free_pcp:1112kB
local_pcp:0kB free_cma:0kB^M
[16212.217075] lowmem_reserve[]: 0 0 0 0^M
[16212.217083] Node 0 DMA: 0*4kB 0*8kB 1*16kB (U) 0*32kB 2*64kB (U)
1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M)
= 15888kB^M
[16212.217093] Node 0 DMA32: 30*4kB (U) 13*8kB (UM) 9*16kB (UM)
17*32kB (UM) 5*64kB (UME) 2*128kB (ME) 2*256kB (UE) 3*512kB (UE)
3*1024kB (UE) 3*2048kB (UME) 27*4096kB (M) = 123344kB^M
[16212.217101] Node 0 Normal: 1259*4kB (UMEH) 3848*8kB (UMEH)
3612*16kB (UMEH) 3740*32kB (UMEH) 3581*64kB (UMEH) 41*128kB (MEH)
12*256kB (UEH) 2*512kB (ME) 2*1024kB (E) 3*2048kB (UME) 0*4096kB =
460012kB^M
[16212.217109] Node 1 Normal: 520*4kB (UMEH) 135*8kB (UMEH) 69*16kB
(UMEH) 31*32kB (UME) 161*64kB (UMEH) 170*128kB (UM) 29*256kB (U)
0*512kB 0*1024kB 0*2048kB 0*4096kB = 44744kB^M
[16212.217110] Node 0 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=1048576kB^M
[16212.217111] Node 0 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=2048kB^M
[16212.217112] Node 1 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=1048576kB^M
[16212.217112] Node 1 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=2048kB^M
[16212.217113] 9058 total pagecache pages^M
[16212.217114] 0 pages in swap cache^M
[16212.217114] Swap cache stats: add 0, delete 0, find 0/0^M
[16212.217115] Free swap  = 0kB^M
[16212.217115] Total swap = 0kB^M
[16212.217116] 16760731 pages RAM^M
[16212.217116] 0 pages HighMem/MovableOnly^M
[16212.217117] 299593 pages reserved^M
[16212.217117] 13 pages hwpoisoned^M
[16213.387131] Hardware name: Dell Inc. PowerEdge C6220/03C9JJ, BIOS
2.2.3 11/07/2013^M
[16213.407413]  ffffaac5cd0bba88 ffffffff86395ab7 ffffffff86a3b280
0000000000000001^M
[16213.436908]  ffffaac5cd0bbb08 ffffffff8619a6c6 024201cacd0bbaf0
ffffffff86a3b280^M
[16213.457248]  ffffaac5cd0bbab0 0100000000000010 ffffaac5cd0bbb18
ffffaac5cd0bbac8^M
[16213.477525] Call Trace:^M
[16213.487314]  [<ffffffff86395ab7>] dump_stack+0x4d/0x66^M
[16213.497723]  [<ffffffff8619a6c6>] warn_alloc+0x116/0x130^M
[16213.505627] NMI watchdog: BUG: soft lockup - CPU#5 stuck for 23s!
[cleanup:7598]^M
[16213.505710] Modules linked in: dummy veth tun xfs libcrc32c
intel_rapl sb_edac edac_core x86_pkg_temp_thermal coretemp
crct10dif_pclmul crc32_pclmul iTCO_wdt iTCO_vendor_support dcdbas
ghash_clmulni_intel lpc_ich i2c_i801 hed wmi i2c_smbus shpchp i2c_core
ioatdma dca acpi_cpufreq tcp_diag inet_diag ipmi_si ipmi_devintf
ipmi_msghandler sch_fq_codel mlx4_en ptp pps_core crc32c_intel
mlx4_core devlink ipv6 crc_ccitt^M
[16213.505713] CPU: 5 PID: 7598 Comm: cleanup Not tainted
4.9.23.el7.twitter.x86_64 #1^M
[16213.505714] Hardware name: Dell Inc. PowerEdge C6220/03C9JJ, BIOS
2.2.3 11/07/2013^M
[16213.505717] task: ffff8af1bf098000 task.stack: ffffaac5e60c8000^M
[16213.505722] RIP: 0010:[<ffffffff86395a93>]  [<ffffffff86395a93>]
dump_stack+0x29/0x66^M
[16213.505724] RSP: 0000:ffffaac5e60cba78  EFLAGS: 00000286^M
[16213.505727] RAX: 0000000000000004 RBX: 0000000000000286 RCX:
00000000ffffffff^M
[16213.505729] RDX: 0000000000000005 RSI: 0000000000000292 RDI:
ffffffff86c51be0^M
[16213.505730] RBP: ffffaac5e60cba88 R08: 0000000000000000 R09:
0000000000000031^M
[16213.505733] R10: 0000000000000000 R11: 0000000003cd5438 R12:
0000000000000001^M
[16213.505737] R13: ffffffff86d43c80 R14: ffff8af1bf098000 R15:
ffffaac5e60cbc40^M
[16213.505742] FS:  00007ff77f22e840(0000) GS:ffff8af1dfb40000(0000)
knlGS:0000000000000000^M
[16213.505746] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033^M
[16213.505748] CR2: 00007fe7603d0650 CR3: 000000022db50000 CR4:
00000000000406e0^M
[16213.505750] Stack:^M
[16213.505767]  ffffffff86a3b280 0000000000000001 ffffaac5e60cbb08
ffffffff8619a6c6^M
[16213.505780]  024201cae60cbaf0 ffffffff86a3b280 ffffaac5e60cbab0
0100000000000010^M
[16213.505792]  ffffaac5e60cbb18 ffffaac5e60cbac8 ffff8af1bf098000
0000000000000000^M
[16213.505795] Call Trace:^M
[16213.505799]  [<ffffffff8619a6c6>] warn_alloc+0x116/0x130^M
[16213.505804]  [<ffffffff8619b0bf>] __alloc_pages_slowpath+0x96f/0xbd0^M
[16213.505807]  [<ffffffff8619b4f6>] __alloc_pages_nodemask+0x1d6/0x230^M
[16213.505810]  [<ffffffff861e61d5>] alloc_pages_current+0x95/0x140^M
[16213.505814]  [<ffffffff8619114a>] __page_cache_alloc+0xca/0xe0^M
[16213.505822]  [<ffffffff86194312>] filemap_fault+0x312/0x4d0^M
[16213.505826]  [<ffffffff862a8196>] ext4_filemap_fault+0x36/0x50^M
[16213.505828]  [<ffffffff861c2c71>] __do_fault+0x71/0x130^M
[16213.505830]  [<ffffffff861c6cec>] handle_mm_fault+0xebc/0x13a0^M
[16213.505832]  [<ffffffff863b434d>] ? list_del+0xd/0x30^M
[16213.505833]  [<ffffffff86257e58>] ? ep_poll+0x308/0x320^M
[16213.505835]  [<ffffffff860509e4>] __do_page_fault+0x254/0x4a0^M
[16213.505837]  [<ffffffff86050c50>] do_page_fault+0x20/0x70^M
[16213.505839]  [<ffffffff86700aa2>] page_fault+0x22/0x30^M
[16213.505877] Code: 5d c3 55 83 c9 ff 48 89 e5 41 54 53 9c 5b fa 65
8b 15 4a 47 c7 79 89 c8 f0 0f b1 15 48 a3 92 00 83 f8 ff 74 0a 39 c2
74 0b 53 9d <f3> 90 eb dd 45 31 e4 eb 06 41 bc 01 00 00 00 48 c7 c7 41
1a a2 ^M
[16214.250659] NMI watchdog: BUG: soft lockup - CPU#17 stuck for 22s!
[scribed:3905]^M
[16214.250762] Modules linked in: dummy veth tun xfs libcrc32c
intel_rapl sb_edac edac_core x86_pkg_temp_thermal coretemp
crct10dif_pclmul crc32_pclmul iTCO_wdt iTCO_vendor_support dcdbas
ghash_clmulni_intel lpc_ich i2c_i801 hed wmi i2c_smbus shpchp i2c_core
ioatdma dca acpi_cpufreq tcp_diag inet_diag ipmi_si ipmi_devintf
ipmi_msghandler sch_fq_codel mlx4_en ptp pps_core crc32c_intel
mlx4_core devlink ipv6 crc_ccitt^M
[16214.250765] CPU: 17 PID: 3905 Comm: scribed Tainted: G
L  4.9.23.el7.twitter.x86_64 #1^M
[16214.250767] Hardware name: Dell Inc. PowerEdge C6220/03C9JJ, BIOS
2.2.3 11/07/2013^M
[16214.250770] task: ffff8af9cb938000 task.stack: ffffaac5cd1c0000^M
[16214.250776] RIP: 0010:[<ffffffff86395a93>]  [<ffffffff86395a93>]
dump_stack+0x29/0x66^M
[16214.250778] RSP: 0000:ffffaac5cd1c3a78  EFLAGS: 00000286^M
[16214.250781] RAX: 0000000000000004 RBX: 0000000000000286 RCX:
00000000ffffffff^M
[16214.250783] RDX: 0000000000000011 RSI: 0000000000000292 RDI:
ffffffff86c51be0^M
[16214.250787] RBP: ffffaac5cd1c3a88 R08: 0000000000000000 R09:
0000000000000031^M
[16214.250789] R10: 0000000000000000 R11: 0000000003cd574c R12:
0000000000000001^M
[16214.250791] R13: ffffffff86d43c80 R14: ffff8af9cb938000 R15:
ffffaac5cd1c3c40^M
[16214.250793] FS:  00007fc4c17fa700(0000) GS:ffff8af1dfcc0000(0000)
knlGS:0000000000000000^M
[16214.250795] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033^M
[16214.250798] CR2: 00007f14196cb650 CR3: 000000083d948000 CR4:
00000000000406e0^M
[16214.250800] Stack:^M
[16214.250815]  ffffffff86a3b280 0000000000000001 ffffaac5cd1c3b08
ffffffff8619a6c6^M
[16214.250827]  024201ca860f0940 ffffffff86a3b280 ffffaac5cd1c3ab0
0000000000000010^M
[16214.250838]  ffffaac5cd1c3b18 ffffaac5cd1c3ac8 000000000000000f
0000000000000000^M
[16214.250840] Call Trace:^M
[16214.250843]  [<ffffffff8619a6c6>] warn_alloc+0x116/0x130^M
[16214.250846]  [<ffffffff8619b0bf>] __alloc_pages_slowpath+0x96f/0xbd0^M
[16214.250849]  [<ffffffff8619b4f6>] __alloc_pages_nodemask+0x1d6/0x230^M
[16214.250853]  [<ffffffff861e61d5>] alloc_pages_current+0x95/0x140^M
[16214.250855]  [<ffffffff8619114a>] __page_cache_alloc+0xca/0xe0^M
[16214.250857]  [<ffffffff86194312>] filemap_fault+0x312/0x4d0^M
[16214.250859]  [<ffffffff862a8196>] ext4_filemap_fault+0x36/0x50^M
[16214.250860]  [<ffffffff861c2c71>] __do_fault+0x71/0x130^M
[16214.250863]  [<ffffffff861c6cec>] handle_mm_fault+0xebc/0x13a0^M
[16214.250865]  [<ffffffff860c25c1>] ? pick_next_task_fair+0x471/0x4a0^M
[16214.250869]  [<ffffffff860509e4>] __do_page_fault+0x254/0x4a0^M
[16214.250871]  [<ffffffff86050c50>] do_page_fault+0x20/0x70^M
[16214.250873]  [<ffffffff86700aa2>] page_fault+0x22/0x30^M
[16214.250918] Code: 5d c3 55 83 c9 ff 48 89 e5 41 54 53 9c 5b fa 65
8b 15 4a 47 c7 79 89 c8 f0 0f b1 15 48 a3 92 00 83 f8 ff 74 0a 39 c2
74 0b 53 9d <f3> 90 eb dd 45 31 e4 eb 06 41 bc 01 00 00 00 48 c7 c7 41
1a a2 ^M
[16215.157526]  [<ffffffff8619b0bf>] __alloc_pages_slowpath+0x96f/0xbd0^M
[16215.177523]  [<ffffffff8619b4f6>] __alloc_pages_nodemask+0x1d6/0x230^M
[16215.197540]  [<ffffffff861e61d5>] alloc_pages_current+0x95/0x140^M
[16215.217331]  [<ffffffff8619114a>] __page_cache_alloc+0xca/0xe0^M
[16215.237374]  [<ffffffff86194312>] filemap_fault+0x312/0x4d0^M
[16215.257136]  [<ffffffff862a8196>] ext4_filemap_fault+0x36/0x50^M
[16215.276950]  [<ffffffff861c2c71>] __do_fault+0x71/0x130^M
[16215.287555]  [<ffffffff861c6cec>] handle_mm_fault+0xebc/0x13a0^M
[16215.307538]  [<ffffffff860509e4>] __do_page_fault+0x254/0x4a0^M
[16215.327165]  [<ffffffff86050c50>] do_page_fault+0x20/0x70^M
[16215.346964]  [<ffffffff86700aa2>] page_fault+0x22/0x30^M
[16215.357554] CPU: 20 PID: 7812 Comm: proxymap Tainted: G
L  4.9.23.el7.twitter.x86_64 #1^M
[16215.357557] Mem-Info:^M
[16215.357563] active_anon:16069475 inactive_anon:5560 isolated_anon:0^M
[16215.357563]  active_file:1319 inactive_file:1356 isolated_file:0^M
[16215.357563]  unevictable:0 dirty:0 writeback:0 unstable:0^M
[16215.357563]  slab_reclaimable:22986 slab_unreclaimable:79813^M
[16215.357563]  mapped:6433 shmem:6364 pagetables:34697 bounce:0^M
[16215.357563]  free:160997 free_pcp:1010 free_cma:0^M
[16215.357567] Node 0 active_anon:31718344kB inactive_anon:8724kB
active_file:5052kB inactive_file:5200kB unevictable:0kB
isolated(anon):0kB isolated(file):0kB mapped:11524kB dirty:0kB
writeback:0kB shmem:8828kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 0kB writeback_tmp:0kB unstable:0kB pages_scanned:39
all_unreclaimable? no^M
[16215.357571] Node 1 active_anon:32559556kB inactive_anon:13516kB
active_file:224kB inactive_file:224kB unevictable:0kB
isolated(anon):0kB isolated(file):0kB mapped:14208kB dirty:0kB
writeback:0kB shmem:16628kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 0kB writeback_tmp:0kB unstable:0kB pages_scanned:683486
all_unreclaimable? yes^M
[16215.357574] Node 0 DMA free:15888kB min:20kB low:32kB high:44kB
active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB
unevictable:0kB writepending:0kB present:15972kB managed:15888kB
mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB
kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB
free_cma:0kB^M
[16215.357576] lowmem_reserve[]: 0 1903 32095 32095^M
[16215.357579] Node 0 DMA32 free:123344kB min:2668kB low:4616kB
high:6564kB active_anon:1820276kB inactive_anon:0kB active_file:0kB
inactive_file:0kB unevictable:0kB writepending:0kB present:2015240kB
managed:1949672kB mlocked:0kB slab_reclaimable:64kB
slab_unreclaimable:2216kB kernel_stack:0kB pagetables:3544kB
bounce:0kB free_pcp:120kB local_pcp:0kB free_cma:0kB^M
[16215.357580] lowmem_reserve[]: 0 0 30191 30191^M
[16215.357584] Node 0 Normal free:460012kB min:42308kB low:73224kB
high:104140kB active_anon:29898068kB inactive_anon:8724kB
active_file:5052kB inactive_file:5200kB unevictable:0kB
writepending:0kB present:31457280kB managed:30916476kB mlocked:0kB
slab_reclaimable:52340kB slab_unreclaimable:172756kB
kernel_stack:5992kB pagetables:64856kB bounce:0kB free_pcp:2808kB
local_pcp:116kB free_cma:0kB^M
[16215.357585] lowmem_reserve[]: 0 0 0 0^M
[16215.357588] Node 1 Normal free:44744kB min:45108kB low:78068kB
high:111028kB active_anon:32559556kB inactive_anon:13516kB
active_file:224kB inactive_file:224kB unevictable:0kB writepending:0kB
present:33554432kB managed:32962516kB mlocked:0kB
slab_reclaimable:39540kB slab_unreclaimable:144280kB
kernel_stack:5224kB pagetables:70388kB bounce:0kB free_pcp:1112kB
local_pcp:0kB free_cma:0kB^M
[16215.357589] lowmem_reserve[]: 0 0 0 0^M
[16215.357595] Node 0 DMA: 0*4kB 0*8kB 1*16kB (U) 0*32kB 2*64kB (U)
1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M)
= 15888kB^M
[16215.357602] Node 0 DMA32: 30*4kB (U) 13*8kB (UM) 9*16kB (UM)
17*32kB (UM) 5*64kB (UME) 2*128kB (ME) 2*256kB (UE) 3*512kB (UE)
3*1024kB (UE) 3*2048kB (UME) 27*4096kB (M) = 123344kB^M
[16215.357609] Node 0 Normal: 1259*4kB (UMEH) 3848*8kB (UMEH)
3612*16kB (UMEH) 3740*32kB (UMEH) 3581*64kB (UMEH) 41*128kB (MEH)
12*256kB (UEH) 2*512kB (ME) 2*1024kB (E) 3*2048kB (UME) 0*4096kB =
460012kB^M
[16215.357614] Node 1 Normal: 520*4kB (UMEH) 135*8kB (UMEH) 69*16kB
(UMEH) 31*32kB (UME) 161*64kB (UMEH) 170*128kB (UM) 29*256kB (U)
0*512kB 0*1024kB 0*2048kB 0*4096kB = 44744kB^M
[16215.357615] Node 0 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=1048576kB^M
[16215.357616] Node 0 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=2048kB^M
[16215.357617] Node 1 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=1048576kB^M
[16215.357618] Node 1 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=2048kB^M
[16215.357618] 9075 total pagecache pages^M
[16215.357619] 0 pages in swap cache^M
[16215.357619] Swap cache stats: add 0, delete 0, find 0/0^M
[16215.357620] Free swap  = 0kB^M
[16215.357620] Total swap = 0kB^M
[16215.357620] 16760731 pages RAM^M
[16215.357621] 0 pages HighMem/MovableOnly^M
[16215.357621] 299593 pages reserved^M
[16215.357621] 13 pages hwpoisoned^M
[16216.520770] warn_alloc: 5 callbacks suppressed^M
[16216.520775] scribed: page allocation stalls for 35691ms, order:0,
mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)^M
[16216.587564] Hardware name: Dell Inc. PowerEdge C6220/03C9JJ, BIOS
2.2.3 11/07/2013^M
[16216.607766]  ffffaac5e6403a88 ffffffff86395ab7 ffffffff86a3b280
0000000000000001[16216.631514] memcg_process_s: ^M
[16216.631519] page allocation stalls for 31710ms, order:0,
mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)^M
[16216.667939]  ffffaac5e6403b08 ffffffff8619a6c6 024201cae6403af0
ffffffff86a3b280^M
[16216.697354]  ffffaac5e6403ab0 0100000000000010 ffffaac5e6403b18
ffffaac5e6403ac8^M
[16216.717761] Call Trace:^M
[16216.727390]  [<ffffffff86395ab7>] dump_stack+0x4d/0x66^M
[16216.746985]  [<ffffffff8619a6c6>] warn_alloc+0x116/0x130^M
[16216.757761]  [<ffffffff8619b0bf>] __alloc_pages_slowpath+0x96f/0xbd0^M
[16216.777571]  [<ffffffff8619b4f6>] __alloc_pages_nodemask+0x1d6/0x230^M
[16216.797558]  [<ffffffff861e61d5>] alloc_pages_current+0x95/0x140^M
[16216.817570]  [<ffffffff8619114a>] __page_cache_alloc+0xca/0xe0^M
[16216.837349]  [<ffffffff86194312>] filemap_fault+0x312/0x4d0^M
[16216.854787] scribed: page allocation stalls for 35977ms, order:0,
mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)^M
[16216.887239]  [<ffffffff862a8196>] ext4_filemap_fault+0x36/0x50^M
[16216.907027]  [<ffffffff861c2c71>] __do_fault+0x71/0x130^M
[16216.917933]  [<ffffffff861c6cec>] handle_mm_fault+0xebc/0x13a0^M
[16216.937650]  [<ffffffff863b434d>] ? list_del+0xd/0x30^M
[16216.957041]  [<ffffffff86257e58>] ? ep_poll+0x308/0x320^M
[16216.967687]  [<ffffffff860509e4>] __do_page_fault+0x254/0x4a0^M
[16216.984835] scribed: page allocation stalls for 36056ms, order:0,
mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)^M
[16217.017608]  [<ffffffff86050c50>] do_page_fault+0x20/0x70^M
[16217.037351]  [<ffffffff86700aa2>] page_fault+0x22/0x30^M
[16217.047932] CPU: 8 PID: 827 Comm: crond Tainted: G             L
4.9.23.el7.twitter.x86_64 #1^M
[16217.047945] Mem-Info:^M
[16217.047955] active_anon:16071724 inactive_anon:3194 isolated_anon:0^M
[16217.047955]  active_file:1617 inactive_file:843 isolated_file:0^M
[16217.047955]  unevictable:0 dirty:0 writeback:0 unstable:0^M
[16217.047955]  slab_reclaimable:22986 slab_unreclaimable:79813^M
[16217.047955]  mapped:5722 shmem:6364 pagetables:34673 bounce:0^M
[16217.047955]  free:161140 free_pcp:1145 free_cma:0^M
[16217.047961] Node 0 active_anon:31722972kB inactive_anon:3628kB
active_file:6244kB inactive_file:3184kB unevictable:0kB
isolated(anon):0kB isolated(file):0kB mapped:9044kB dirty:0kB
writeback:0kB shmem:8828kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 0kB writeback_tmp:0kB unstable:0kB pages_scanned:29
all_unreclaimable? no^M
[16217.047966] Node 1 active_anon:32563924kB inactive_anon:9148kB
active_file:224kB inactive_file:188kB unevictable:0kB
isolated(anon):0kB isolated(file):0kB mapped:13844kB dirty:0kB
writeback:0kB shmem:16628kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 0kB writeback_tmp:0kB unstable:0kB pages_scanned:686021
all_unreclaimable? yes^M
[16217.047970] Node 0 DMA free:15888kB min:20kB low:32kB high:44kB
active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB
unevictable:0kB writepending:0kB present:15972kB managed:15888kB
mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB
kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB
free_cma:0kB^M
[16217.047972] lowmem_reserve[]: 0 1903 32095 32095^M
[16217.047976] Node 0 DMA32 free:123344kB min:2668kB low:4616kB
high:6564kB active_anon:1820276kB inactive_anon:0kB active_file:0kB
inactive_file:0kB unevictable:0kB writepending:0kB present:2015240kB
managed:1949672kB mlocked:0kB slab_reclaimable:64kB
slab_unreclaimable:2216kB kernel_stack:0kB pagetables:3544kB
bounce:0kB free_pcp:120kB local_pcp:0kB free_cma:0kB^M
[16217.047978] lowmem_reserve[]: 0 0 30191 30191^M
[16217.047982] Node 0 Normal free:460584kB min:42308kB low:73224kB
high:104140kB active_anon:29902696kB inactive_anon:3628kB
active_file:6244kB inactive_file:3184kB unevictable:0kB
writepending:0kB present:31457280kB managed:30916476kB mlocked:0kB
slab_reclaimable:52340kB slab_unreclaimable:172756kB
kernel_stack:5976kB pagetables:64760kB bounce:0kB free_pcp:3204kB
local_pcp:0kB free_cma:0kB^M
[16217.047984] lowmem_reserve[]: 0 0 0 0^M
[16217.047988] Node 1 Normal free:44744kB min:45108kB low:78068kB
high:111028kB active_anon:32563924kB inactive_anon:9148kB
active_file:224kB inactive_file:188kB unevictable:0kB writepending:0kB
present:33554432kB managed:32962516kB mlocked:0kB
slab_reclaimable:39540kB slab_unreclaimable:144280kB
kernel_stack:5224kB pagetables:70388kB bounce:0kB free_pcp:1256kB
local_pcp:116kB free_cma:0kB^M
[16217.047989] lowmem_reserve[]: 0 0 0 0^M
[16217.047997] Node 0 DMA: 0*4kB 0*8kB 1*16kB (U) 0*32kB 2*64kB (U)
1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M)
= 15888kB^M
[16217.048007] Node 0 DMA32: 30*4kB (U) 13*8kB (UM) 9*16kB (UM)
17*32kB (UM) 5*64kB (UME) 2*128kB (ME) 2*256kB (UE) 3*512kB (UE)
3*1024kB (UE) 3*2048kB (UME) 27*4096kB (M) = 123344kB^M
[16217.048015] Node 0 Normal: 1352*4kB (UMEH) 3846*8kB (UMEH)
3610*16kB (UMEH) 3742*32kB (UMEH) 3581*64kB (UMEH) 41*128kB (MEH)
12*256kB (UEH) 2*512kB (ME) 2*1024kB (E) 3*2048kB (UME) 0*4096kB =
460400kB^M
[16217.048023] Node 1 Normal: 520*4kB (UMEH) 135*8kB (UMEH) 69*16kB
(UMEH) 31*32kB (UME) 161*64kB (UMEH) 170*128kB (UM) 29*256kB (U)
0*512kB 0*1024kB 0*2048kB 0*4096kB = 44744kB^M
[16217.048025] Node 0 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=1048576kB^M
[16217.048026] Node 0 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=2048kB^M
[16217.048026] Node 1 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=1048576kB^M
[16217.048027] Node 1 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=2048kB^M
[16217.048028] 8969 total pagecache pages^M
[16217.048029] 0 pages in swap cache^M
[16217.048030] Swap cache stats: add 0, delete 0, find 0/0^M
[16217.048030] Free swap  = 0kB^M
[16217.048031] Total swap = 0kB^M
[16217.048031] 16760731 pages RAM^M
[16217.048032] 0 pages HighMem/MovableOnly^M
[16217.048032] 299593 pages reserved^M
[16217.048033] 13 pages hwpoisoned^M
[16217.075797] memcg_process_s: page allocation stalls for 32206ms,
order:0, mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
