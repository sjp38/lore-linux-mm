Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id AAB846B0069
	for <linux-mm@kvack.org>; Sun,  1 Jan 2017 12:20:59 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id m203so73536773wma.2
        for <linux-mm@kvack.org>; Sun, 01 Jan 2017 09:20:59 -0800 (PST)
Received: from vps01.wiesinger.com (vps01.wiesinger.com. [46.36.37.179])
        by mx.google.com with ESMTPS id qj8si70118712wjb.165.2017.01.01.09.20.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Jan 2017 09:20:57 -0800 (PST)
Subject: Re: Still OOM problems with 4.9er kernels
References: <aa4a3217-f94c-0477-b573-796c84255d1e@wiesinger.com>
 <c4ddfc91-7c84-19ed-b69a-18403e7590f9@wiesinger.com>
 <b3d7a0f3-caa4-91f9-4148-b62cf5e23886@wiesinger.com>
 <20161209134025.GB4342@dhcp22.suse.cz>
 <a0bf765f-d5dd-7a51-1a6b-39cbda56bd58@wiesinger.com>
 <20161223025505.GA30876@bbox>
From: Gerhard Wiesinger <lists@wiesinger.com>
Message-ID: <4f4bab82-f8e1-2fb2-01ee-1c7a780f3bc9@wiesinger.com>
Date: Sun, 1 Jan 2017 18:20:31 +0100
MIME-Version: 1.0
In-Reply-To: <20161223025505.GA30876@bbox>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On 23.12.2016 03:55, Minchan Kim wrote:
> On Fri, Dec 09, 2016 at 04:52:07PM +0100, Gerhard Wiesinger wrote:
>> On 09.12.2016 14:40, Michal Hocko wrote:
>>> On Fri 09-12-16 08:06:25, Gerhard Wiesinger wrote:
>>>> Hello,
>>>>
>>>> same with latest kernel rc, dnf still killed with OOM (but sometimes
>>>> better).
>>>>
>>>> ./update.sh: line 40:  1591 Killed                  ${EXE} update ${PARAMS}
>>>> (does dnf clean all;dnf update)
>>>> Linux database.intern 4.9.0-0.rc8.git2.1.fc26.x86_64 #1 SMP Wed Dec 7
>>>> 17:53:29 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux
>>>>
>>>> Updated bug report:
>>>> https://bugzilla.redhat.com/show_bug.cgi?id=1314697
>>> Could you post your oom report please?
>> E.g. a new one with more than one included, first one after boot ...
>>
>> Just setup a low mem VM under KVM and it is easily triggerable.
>>
>> Still enough virtual memory available ...
>>
>> 4.9.0-0.rc8.git2.1.fc26.x86_64
>>
>> [  624.862777] ksoftirqd/0: page allocation failure: order:0,
>> mode:0x2080020(GFP_ATOMIC)
>> [  624.863319] CPU: 0 PID: 3 Comm: ksoftirqd/0 Not tainted
>> 4.9.0-0.rc8.git2.1.fc26.x86_64 #1
>> [  624.863410] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
>> 1.9.3
>> [  624.863510]  ffffaa62c007f958 ffffffff904774e3 ffffffff90c7dd98
>> 0000000000000000
>> [  624.863923]  ffffaa62c007f9e0 ffffffff9020e6ea 0208002000000246
>> ffffffff90c7dd98
>> [  624.864019]  ffffaa62c007f980 ffff96b900000010 ffffaa62c007f9f0
>> ffffaa62c007f9a0
>> [  624.864998] Call Trace:
>> [  624.865149]  [<ffffffff904774e3>] dump_stack+0x86/0xc3
>> [  624.865347]  [<ffffffff9020e6ea>] warn_alloc+0x13a/0x170
>> [  624.865432]  [<ffffffff9020e9e2>] __alloc_pages_slowpath+0x252/0xbb0
>> [  624.865563]  [<ffffffff9020f74d>] __alloc_pages_nodemask+0x40d/0x4b0
>> [  624.865675]  [<ffffffff9020f983>] __alloc_page_frag+0x193/0x200
>> [  624.866024]  [<ffffffff907a1d7e>] __napi_alloc_skb+0x8e/0xf0
>> [  624.866113]  [<ffffffffc017777d>] page_to_skb.isra.28+0x5d/0x310
>> [virtio_net]
>> [  624.866201]  [<ffffffffc01794cb>] virtnet_receive+0x2db/0x9a0
>> [virtio_net]
>> [  624.867378]  [<ffffffffc0179bad>] virtnet_poll+0x1d/0x80 [virtio_net]
>> [  624.867494]  [<ffffffff907b501e>] net_rx_action+0x23e/0x470
>> [  624.867612]  [<ffffffff9091a8cd>] __do_softirq+0xcd/0x4b9
>> [  624.867704]  [<ffffffff900dd164>] ? smpboot_thread_fn+0x34/0x1f0
>> [  624.867833]  [<ffffffff900dd25d>] ? smpboot_thread_fn+0x12d/0x1f0
>> [  624.867924]  [<ffffffff900b7c95>] run_ksoftirqd+0x25/0x80
>> [  624.868109]  [<ffffffff900dd258>] smpboot_thread_fn+0x128/0x1f0
>> [  624.868197]  [<ffffffff900dd130>] ? sort_range+0x30/0x30
>> [  624.868596]  [<ffffffff900d82c2>] kthread+0x102/0x120
>> [  624.868679]  [<ffffffff909117a0>] ? wait_for_completion+0x110/0x140
>> [  624.868768]  [<ffffffff900d81c0>] ? kthread_park+0x60/0x60
>> [  624.868850]  [<ffffffff90917afa>] ret_from_fork+0x2a/0x40
>> [  843.528656] httpd (2490) used greatest stack depth: 10304 bytes left
>> [  878.077750] httpd (2976) used greatest stack depth: 10096 bytes left
>> [93918.861109] netstat (14579) used greatest stack depth: 9488 bytes left
>> [94050.874669] kworker/dying (6253) used greatest stack depth: 9008 bytes
>> left
>> [95895.765570] kworker/1:1H: page allocation failure: order:0,
>> mode:0x2280020(GFP_ATOMIC|__GFP_NOTRACK)
>> [95895.765819] CPU: 1 PID: 440 Comm: kworker/1:1H Not tainted
>> 4.9.0-0.rc8.git2.1.fc26.x86_64 #1
>> [95895.765911] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
>> 1.9.3
>> [95895.766060] Workqueue: kblockd blk_mq_run_work_fn
>> [95895.766143]  ffffaa62c0257628 ffffffff904774e3 ffffffff90c7dd98
>> 0000000000000000
>> [95895.766235]  ffffaa62c02576b0 ffffffff9020e6ea 0228002000000046
>> ffffffff90c7dd98
>> [95895.766325]  ffffaa62c0257650 ffff96b900000010 ffffaa62c02576c0
>> ffffaa62c0257670
>> [95895.766417] Call Trace:
>> [95895.766502]  [<ffffffff904774e3>] dump_stack+0x86/0xc3
>> [95895.766596]  [<ffffffff9020e6ea>] warn_alloc+0x13a/0x170
>> [95895.766681]  [<ffffffff9020e9e2>] __alloc_pages_slowpath+0x252/0xbb0
>> [95895.766767]  [<ffffffff9020f74d>] __alloc_pages_nodemask+0x40d/0x4b0
>> [95895.766866]  [<ffffffff9026db51>] alloc_pages_current+0xa1/0x1f0
>> [95895.766971]  [<ffffffff90916f17>] ? _raw_spin_unlock+0x27/0x40
>> [95895.767073]  [<ffffffff90278956>] new_slab+0x316/0x7c0
>> [95895.767160]  [<ffffffff9027ae8b>] ___slab_alloc+0x3fb/0x5c0
>> [95895.772611]  [<ffffffff9010b042>] ? cpuacct_charge+0xf2/0x1f0
>> [95895.773406]  [<ffffffffc005850d>] ? alloc_indirect.isra.11+0x1d/0x50
>> [virtio_ring]
>> [95895.774327]  [<ffffffff901319d5>] ? rcu_read_lock_sched_held+0x45/0x80
>> [95895.775212]  [<ffffffffc005850d>] ? alloc_indirect.isra.11+0x1d/0x50
>> [virtio_ring]
>> [95895.776155]  [<ffffffff9027b0a1>] __slab_alloc+0x51/0x90
>> [95895.777090]  [<ffffffff9027d141>] __kmalloc+0x251/0x320
>> [95895.781502]  [<ffffffffc005850d>] ? alloc_indirect.isra.11+0x1d/0x50
>> [virtio_ring]
>> [95895.782309]  [<ffffffffc005850d>] alloc_indirect.isra.11+0x1d/0x50
>> [virtio_ring]
>> [95895.783334]  [<ffffffffc0059193>] virtqueue_add_sgs+0x1c3/0x4a0
>> [virtio_ring]
>> [95895.784059]  [<ffffffff90068475>] ? kvm_sched_clock_read+0x25/0x40
>> [95895.784742]  [<ffffffffc006665c>] __virtblk_add_req+0xbc/0x220
>> [virtio_blk]
>> [95895.785419]  [<ffffffff901312fd>] ? debug_lockdep_rcu_enabled+0x1d/0x20
>> [95895.786086]  [<ffffffffc0066935>] ? virtio_queue_rq+0x105/0x290
>> [virtio_blk]
>> [95895.786750]  [<ffffffffc006695d>] virtio_queue_rq+0x12d/0x290
>> [virtio_blk]
>> [95895.787427]  [<ffffffff9045015d>] __blk_mq_run_hw_queue+0x26d/0x3b0
>> [95895.788106]  [<ffffffff904502e2>] blk_mq_run_work_fn+0x12/0x20
>> [95895.789065]  [<ffffffff900d097e>] process_one_work+0x23e/0x6f0
>> [95895.789741]  [<ffffffff900d08fa>] ? process_one_work+0x1ba/0x6f0
>> [95895.790444]  [<ffffffff900d0e7e>] worker_thread+0x4e/0x490
>> [95895.791178]  [<ffffffff900d0e30>] ? process_one_work+0x6f0/0x6f0
>> [95895.791911]  [<ffffffff900d0e30>] ? process_one_work+0x6f0/0x6f0
>> [95895.792653]  [<ffffffff90003eec>] ? do_syscall_64+0x6c/0x1f0
>> [95895.793397]  [<ffffffff900d82c2>] kthread+0x102/0x120
>> [95895.794212]  [<ffffffff90111775>] ? trace_hardirqs_on_caller+0xf5/0x1b0
>> [95895.794942]  [<ffffffff900d81c0>] ? kthread_park+0x60/0x60
>> [95895.795689]  [<ffffffff90917afa>] ret_from_fork+0x2a/0x40
>> [95895.796408] Mem-Info:
>> [95895.797110] active_anon:8800 inactive_anon:9030 isolated_anon:32
>>                  active_file:263 inactive_file:238 isolated_file:0
>>                  unevictable:0 dirty:0 writeback:330 unstable:0
>>                  slab_reclaimable:5241 slab_unreclaimable:9538
>>                  mapped:470 shmem:9 pagetables:2200 bounce:0
>>                  free:690 free_pcp:68 free_cma:0
>> [95895.801218] Node 0 active_anon:35200kB inactive_anon:36120kB
>> active_file:1052kB inactive_file:952kB unevictable:0kB isolated(anon):128kB
>> isolated(file):0kB mapped:1880kB dirty:0kB writeback:1320kB shmem:0kB
>> shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 36kB writeback_tmp:0kB
>> unstable:0kB pages_scanned:179 all_unreclaimable? no
>> [95895.803264] Node 0 DMA free:924kB min:172kB low:212kB high:252kB
>> active_anon:3544kB inactive_anon:3944kB active_file:84kB inactive_file:140kB
>> unevictable:0kB writepending:4kB present:15992kB managed:15908kB mlocked:0kB
>> slab_reclaimable:1728kB slab_unreclaimable:2964kB kernel_stack:84kB
>> pagetables:1396kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
>> [95895.805936] lowmem_reserve[]: 0 117 117 117 117
>> [95895.806751] Node 0 DMA32 free:1836kB min:1296kB low:1620kB high:1944kB
>> active_anon:31636kB inactive_anon:32164kB active_file:968kB
>> inactive_file:804kB unevictable:0kB writepending:1288kB present:180080kB
>> managed:139012kB mlocked:0kB slab_reclaimable:19236kB
>> slab_unreclaimable:35188kB kernel_stack:1852kB pagetables:7404kB bounce:0kB
>> free_pcp:272kB local_pcp:156kB free_cma:0kB
>> [95895.809223] lowmem_reserve[]: 0 0 0 0 0
>> [95895.810071] Node 0 DMA: 36*4kB (H) 29*8kB (H) 22*16kB (H) 6*32kB (H)
>> 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 920kB
>> [95895.812089] Node 0 DMA32: 77*4kB (H) 71*8kB (H) 28*16kB (H) 8*32kB (H)
>> 4*64kB (H) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1836kB
>> [95895.813979] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0
>> hugepages_size=2048kB
>> [95895.813981] 1804 total pagecache pages
>> [95895.814931] 1289 pages in swap cache
>> [95895.815849] Swap cache stats: add 5288014, delete 5286725, find
>> 11568655/13881082
>> [95895.816792] Free swap  = 1791816kB
>> [95895.817706] Total swap = 2064380kB
>> [95895.819222] 49018 pages RAM
>> [95895.820145] 0 pages HighMem/MovableOnly
>> [95895.821039] 10288 pages reserved
>> [95895.823325] 0 pages cma reserved
>> [95895.824244] 0 pages hwpoisoned
>> [95895.825237] SLUB: Unable to allocate memory on node -1,
>> gfp=0x2080020(GFP_ATOMIC)
>> [95895.826140]   cache: kmalloc-256, object size: 256, buffer size: 256,
>> default order: 0, min order: 0
>> [95895.827034]   node 0: slabs: 113, objs: 1808, free: 0
>> [97883.838418] httpd invoked oom-killer:
>> gfp_mask=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD), nodemask=0, order=0,
>> oom_score_adj=0
>> [97883.843507] httpd cpuset=/ mems_allowed=0
>> [97883.843601] CPU: 1 PID: 19043 Comm: httpd Not tainted
>> 4.9.0-0.rc8.git2.1.fc26.x86_64 #1
>> [97883.844628] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
>> 1.9.3
>> [97883.845839]  ffffaa62c395f958 ffffffff904774e3 ffffaa62c395fb20
>> ffff96b98b8b3100
>> [97883.846970]  ffffaa62c395f9e0 ffffffff902a8c41 0000000000000000
>> 0000000000000000
>> [97883.848388]  ffffffff90ec6840 ffffaa62c395f990 ffffffff9011183d
>> ffffaa62c395f9b0
>> [97883.849945] Call Trace:
>> [97883.851366]  [<ffffffff904774e3>] dump_stack+0x86/0xc3
>> [97883.852535]  [<ffffffff902a8c41>] dump_header+0x7b/0x24f
>> [97883.853718]  [<ffffffff9011183d>] ? trace_hardirqs_on+0xd/0x10
>> [97883.854857]  [<ffffffff902085d3>] oom_kill_process+0x203/0x3e0
>> [97883.856192]  [<ffffffff90208afb>] out_of_memory+0x13b/0x580
>> [97883.857334]  [<ffffffff90208bea>] ? out_of_memory+0x22a/0x580
>> [97883.858590]  [<ffffffff9020f31a>] __alloc_pages_slowpath+0xb8a/0xbb0
>> [97883.859706]  [<ffffffff9020f74d>] __alloc_pages_nodemask+0x40d/0x4b0
>> [97883.860854]  [<ffffffff90037de9>] ? sched_clock+0x9/0x10
>> [97883.862120]  [<ffffffff9026db51>] alloc_pages_current+0xa1/0x1f0
>> [97883.863251]  [<ffffffff90201d96>] __page_cache_alloc+0x146/0x190
>> [97883.864449]  [<ffffffff9020366c>] ? pagecache_get_page+0x2c/0x300
>> [97883.865602]  [<ffffffff90206055>] filemap_fault+0x345/0x790
>> [97883.866661]  [<ffffffff90206238>] ? filemap_fault+0x528/0x790
>> [97883.867795]  [<ffffffff903639d9>] ext4_filemap_fault+0x39/0x50
>> [97883.869289]  [<ffffffff90241ca3>] __do_fault+0x83/0x1d0
>> [97883.870301]  [<ffffffff90246642>] handle_mm_fault+0x11e2/0x17a0
>> [97883.871304]  [<ffffffff902454ba>] ? handle_mm_fault+0x5a/0x17a0
>> [97883.872491]  [<ffffffff9006de16>] __do_page_fault+0x266/0x520
>> [97883.873406]  [<ffffffff9006e1a8>] trace_do_page_fault+0x58/0x2a0
>> [97883.874262]  [<ffffffff90067f3a>] do_async_page_fault+0x1a/0xa0
>> [97883.875168]  [<ffffffff90918e28>] async_page_fault+0x28/0x30
>> [97883.882611] Mem-Info:
>> [97883.883747] active_anon:2915 inactive_anon:3376 isolated_anon:0
>>                  active_file:3902 inactive_file:3639 isolated_file:0
>>                  unevictable:0 dirty:205 writeback:0 unstable:0
>>                  slab_reclaimable:9856 slab_unreclaimable:9682
>>                  mapped:3722 shmem:59 pagetables:2080 bounce:0
>>                  free:748 free_pcp:15 free_cma:0
>> [97883.890766] Node 0 active_anon:11660kB inactive_anon:13504kB
>> active_file:15608kB inactive_file:14556kB unevictable:0kB isolated(anon):0kB
>> isolated(file):0kB mapped:14888kB dirty:820kB writeback:0kB shmem:0kB
>> shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 236kB writeback_tmp:0kB
>> unstable:0kB pages_scanned:168352 all_unreclaimable? yes
>> [97883.893210] Node 0 DMA free:1468kB min:172kB low:212kB high:252kB
>> active_anon:1716kB inactive_anon:912kB active_file:2292kB
>> inactive_file:876kB unevictable:0kB writepending:24kB present:15992kB
>> managed:15908kB mlocked:0kB slab_reclaimable:4652kB
>> slab_unreclaimable:2852kB kernel_stack:76kB pagetables:496kB bounce:0kB
>> free_pcp:0kB local_pcp:0kB free_cma:0kB
>> [97883.898799] lowmem_reserve[]: 0 117 117 117 117
>> [97883.899735] Node 0 DMA32 free:1524kB min:1296kB low:1620kB high:1944kB
>> active_anon:9944kB inactive_anon:12572kB active_file:13316kB
>> inactive_file:13680kB unevictable:0kB writepending:768kB present:180080kB
>> managed:139012kB mlocked:0kB slab_reclaimable:34772kB
>> slab_unreclaimable:35876kB kernel_stack:1828kB pagetables:7824kB bounce:0kB
>> free_pcp:60kB local_pcp:52kB free_cma:0kB
>> [97883.903033] lowmem_reserve[]: 0 0 0 0 0
>> [97883.904371] Node 0 DMA: 36*4kB (H) 29*8kB (H) 22*16kB (H) 9*32kB (H)
>> 3*64kB (H) 2*128kB (H) 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1464kB
>> [97883.906442] Node 0 DMA32: 13*4kB (H) 4*8kB (H) 13*16kB (H) 8*32kB (H)
>> 9*64kB (H) 1*128kB (H) 1*256kB (H) 0*512kB 0*1024kB 0*2048kB 0*4096kB =
>> 1508kB
> (H) mean highorder atomic reserved which was introduced since v4.4 and some
> patches to use up that reserved memory went to linux-next recently via mmotm
> tree.
> It doesn't land to 4.9 so it might help to test recent linux-next tree.
> It should include [1].
>
> [1] 04c8716f7b00, mm: try to exhaust highatomic reserve before the OOM
>

Hello Minchan,

4.10.0-0.rc0.git9.1.fc26.x86_64
No still OOMs. I'll send you the infos per private mail.

Ciao,
Gerhard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
