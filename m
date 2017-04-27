Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6CCFC6B02E1
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 05:06:44 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id d3so21619048pfj.5
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 02:06:44 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id g34si1950442pld.328.2017.04.27.02.06.41
        for <linux-mm@kvack.org>;
        Thu, 27 Apr 2017 02:06:43 -0700 (PDT)
Subject: 4.11.0-rc8+/x86_64 desktop lockup until applications closed
References: <md5:RQiZYAYNN/yJzTrY48XZ7w==>
From: Arthur Marsh <arthur.marsh@internode.on.net>
Message-ID: <ccd5aac8-b24a-713a-db54-c35688905595@internode.on.net>
Date: Thu, 27 Apr 2017 18:36:38 +0930
MIME-Version: 1.0
In-Reply-To: <md5:RQiZYAYNN/yJzTrY48XZ7w==>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org


I came home yesterday to discover my desktop KDE/plasma session locked 
up until I could shutdown firefox and chromium from a console login.

The desktop then became responsive and I could then restart firefox and 
chromium.

the 4GiB swap space was nearly full, but the OOM killer apparently 
didn't run.

dmesg showed:


[55363.482931] QXcbEventReader: page allocation stalls for 10048ms, 
order:0, mode:0x14200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null)
[55363.482942] QXcbEventReader cpuset=/ mems_allowed=0
[55363.482948] CPU: 2 PID: 4092 Comm: QXcbEventReader Not tainted 
4.11.0-rc8+ #2670
[55363.482950] Hardware name: System manufacturer System Product 
Name/M3A78 PRO, BIOS 1701    01/27/2011
[55363.482951] Call Trace:
[55363.482959]  ? dump_stack+0x5c/0x84
[55363.482962]  ? warn_alloc+0x112/0x1b0
[55363.482964]  ? __alloc_pages_slowpath+0x836/0xde0
[55363.482967]  ? ktime_get+0x51/0xd0
[55363.482979]  ? scsi_request_fn+0x3d/0x690 [scsi_mod]
[55363.482981]  ? __alloc_pages_nodemask+0x1eb/0x230
[55363.482984]  ? alloc_pages_vma+0xc4/0x280
[55363.482987]  ? __read_swap_cache_async+0x189/0x280
[55363.482990]  ? read_swap_cache_async+0x24/0x60
[55363.482991]  ? swapin_readahead+0x10d/0x1c0
[55363.482994]  ? do_swap_page+0x272/0x720
[55363.482997]  ? __handle_mm_fault+0x773/0x10f0
[55363.482999]  ? handle_mm_fault+0xe7/0x260
[55363.483002]  ? __do_page_fault+0x2d4/0x630
[55363.483005]  ? page_fault+0x28/0x30
[55363.483008]  ? copy_user_generic_string+0x2c/0x40
[55363.483011]  ? copy_page_to_iter+0x91/0x2d0
[55363.483014]  ? skb_copy_datagram_iter+0x146/0x270
[55363.483016]  ? unix_stream_read_actor+0x1a/0x30
[55363.483018]  ? unix_stream_read_generic+0x2f8/0x8c0
[55363.483020]  ? _raw_spin_lock+0x13/0x40
[55363.483022]  ? _raw_spin_unlock_irq+0x1d/0x40
[55363.483024]  ? free_swap_slot+0x4e/0x110
[55363.483026]  ? _raw_spin_unlock+0x16/0x40
[55363.483028]  ? unix_stream_recvmsg+0x81/0xa0
[55363.483029]  ? unix_state_double_unlock+0x40/0x40
[55363.483031]  ? SYSC_recvfrom+0xe3/0x170
[55363.483034]  ? handle_mm_fault+0xe7/0x260
[55363.483036]  ? __do_page_fault+0x301/0x630
[55363.483038]  ? entry_SYSCALL_64_fastpath+0x1e/0xad
[55363.483040] Mem-Info:
[55363.483044] active_anon:1479559 inactive_anon:281161 isolated_anon:299
                 active_file:49213 inactive_file:42134 isolated_file:0
                 unevictable:4651 dirty:108 writeback:188 unstable:0
                 slab_reclaimable:11225 slab_unreclaimable:20186
                 mapped:204768 shmem:145888 pagetables:39859 bounce:0
                 free:25470 free_pcp:0 free_cma:0
[55363.483050] Node 0 active_anon:5918236kB inactive_anon:1124644kB 
active_file:196852kB inactive_file:168536kB unevictable:18604kB 
isolated(anon):1196kB isolated(file):0kB mapped:819072kB dirty:432kB 
writeback:752kB shmem:583552kB shmem_thp: 0kB shmem_pmdmapped: 0kB 
anon_thp: 0kB writeback_tmp:0kB unstable:0kB pages_scanned:0 
all_unreclaimable? no
[55363.483052] Node 0 DMA free:15904kB min:132kB low:164kB high:196kB 
active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB 
unevictable:0kB writepending:0kB present:15992kB managed:15904kB 
mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB 
pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[55363.483056] lowmem_reserve[]: 0 3150 7885 7885
[55363.483059] Node 0 DMA32 free:45556kB min:26948kB low:33684kB 
high:40420kB active_anon:2273532kB inactive_anon:542768kB 
active_file:99788kB inactive_file:89940kB unevictable:32kB 
writepending:440kB present:3391168kB managed:3314260kB mlocked:32kB 
slab_reclaimable:8800kB slab_unreclaimable:25976kB kernel_stack:7992kB 
pagetables:68028kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[55363.483063] lowmem_reserve[]: 0 0 4734 4734
[55363.483066] Node 0 Normal free:40420kB min:40500kB low:50624kB 
high:60748kB active_anon:3644668kB inactive_anon:581672kB 
active_file:97068kB inactive_file:78784kB unevictable:18572kB 
writepending:0kB present:4980736kB managed:4848692kB mlocked:18572kB 
slab_reclaimable:36100kB slab_unreclaimable:54768kB kernel_stack:13544kB 
pagetables:91408kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[55363.483069] lowmem_reserve[]: 0 0 0 0
[55363.483072] Node 0 DMA: 0*4kB 0*8kB 0*16kB 1*32kB (U) 2*64kB (U) 
1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) = 
15904kB
[55363.483081] Node 0 DMA32: 422*4kB (UME) 847*8kB (UME) 734*16kB (UME) 
338*32kB (UME) 108*64kB (UME) 23*128kB (UME) 9*256kB (M) 3*512kB (M) 
2*1024kB (M) 0*2048kB 0*4096kB = 46768kB
[55363.483090] Node 0 Normal: 1293*4kB (UME) 1451*8kB (UME) 845*16kB 
(UME) 293*32kB (UME) 36*64kB (UM) 0*128kB 0*256kB 0*512kB 0*1024kB 
0*2048kB 0*4096kB = 41980kB
[55363.483099] Node 0 hugepages_total=0 hugepages_free=0 
hugepages_surp=0 hugepages_size=1048576kB
[55363.483100] Node 0 hugepages_total=0 hugepages_free=0 
hugepages_surp=0 hugepages_size=2048kB
[55363.483101] 251525 total pagecache pages
[55363.483104] 10025 pages in swap cache
[55363.483105] Swap cache stats: add 3287896, delete 3277870, find 
405176/629612
[55363.483106] Free swap  = 498568kB
[55363.483107] Total swap = 4194288kB
[55363.483108] 2096974 pages RAM
[55363.483109] 0 pages HighMem/MovableOnly
[55363.483110] 52260 pages reserved
[55363.483111] 0 pages hwpoisoned

I'm happy to supply configuation information and run further tests.

Arthur.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
