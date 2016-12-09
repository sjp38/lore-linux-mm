Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2793A6B0261
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 11:07:20 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id m203so7721638wma.2
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 08:07:20 -0800 (PST)
Received: from vps01.wiesinger.com (vps01.wiesinger.com. [46.36.37.179])
        by mx.google.com with ESMTPS id lg5si34704055wjc.131.2016.12.09.08.07.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Dec 2016 08:07:18 -0800 (PST)
Subject: Re: Still OOM problems with 4.9er kernels
References: <aa4a3217-f94c-0477-b573-796c84255d1e@wiesinger.com>
 <c4ddfc91-7c84-19ed-b69a-18403e7590f9@wiesinger.com>
 <b3d7a0f3-caa4-91f9-4148-b62cf5e23886@wiesinger.com>
 <20161209134025.GB4342@dhcp22.suse.cz>
From: Gerhard Wiesinger <lists@wiesinger.com>
Message-ID: <c0acd9dc-0c80-ddb6-aa64-02e19051fe81@wiesinger.com>
Date: Fri, 9 Dec 2016 17:03:52 +0100
MIME-Version: 1.0
In-Reply-To: <20161209134025.GB4342@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On 09.12.2016 14:40, Michal Hocko wrote:
> On Fri 09-12-16 08:06:25, Gerhard Wiesinger wrote:
>> Hello,
>>
>> same with latest kernel rc, dnf still killed with OOM (but sometimes
>> better).
>>
>> ./update.sh: line 40:  1591 Killed                  ${EXE} update ${PARAMS}
>> (does dnf clean all;dnf update)
>> Linux database.intern 4.9.0-0.rc8.git2.1.fc26.x86_64 #1 SMP Wed Dec 7
>> 17:53:29 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux
>>
>> Updated bug report:
>> https://bugzilla.redhat.com/show_bug.cgi?id=1314697
> Could you post your oom report please?

And another one which ended in a native_safe_halt ....

[73366.837826] nmbd: page allocation failure: order:0, 
mode:0x2280030(GFP_ATOMIC|__GFP_RECLAIMABLE|__GFP_NOTRACK)
[73366.837985] CPU: 1 PID: 2005 Comm: nmbd Not tainted 
4.9.0-0.rc8.git2.1.fc26.x86_64 #1
[73366.838075] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), 
BIOS 1.9.3
[73366.838175]  ffffaa4ac059f548 ffffffff8d4774e3 ffffffff8dc7dd98 
0000000000000000
[73366.838272]  ffffaa4ac059f5d0 ffffffff8d20e6ea 0228003000000046 
ffffffff8dc7dd98
[73366.838364]  ffffaa4ac059f570 ffff9c3700000010 ffffaa4ac059f5e0 
ffffaa4ac059f590
[73366.838458] Call Trace:
[73366.838590]  [<ffffffff8d4774e3>] dump_stack+0x86/0xc3
[73366.838680]  [<ffffffff8d20e6ea>] warn_alloc+0x13a/0x170
[73366.838762]  [<ffffffff8d20e9e2>] __alloc_pages_slowpath+0x252/0xbb0
[73366.838846]  [<ffffffff8d0e09a0>] ? finish_task_switch+0xb0/0x260
[73366.838926]  [<ffffffff8d20f74d>] __alloc_pages_nodemask+0x40d/0x4b0
[73366.839007]  [<ffffffff8d26db51>] alloc_pages_current+0xa1/0x1f0
[73366.839088]  [<ffffffff8d068475>] ? kvm_sched_clock_read+0x25/0x40
[73366.839170]  [<ffffffff8d278956>] new_slab+0x316/0x7c0
[73366.839245]  [<ffffffff8d27ae8b>] ___slab_alloc+0x3fb/0x5c0
[73366.839325]  [<ffffffff8d068475>] ? kvm_sched_clock_read+0x25/0x40
[73366.839409]  [<ffffffff8d3a4503>] ? __es_insert_extent+0xb3/0x330
[73366.839501]  [<ffffffff8d3a4503>] ? __es_insert_extent+0xb3/0x330
[73366.839583]  [<ffffffff8d27b0a1>] __slab_alloc+0x51/0x90
[73366.839662]  [<ffffffff8d3a4503>] ? __es_insert_extent+0xb3/0x330
[73366.839743]  [<ffffffff8d27b326>] kmem_cache_alloc+0x246/0x2d0
[73366.839822]  [<ffffffff8d3a5066>] ? __es_remove_extent+0x56/0x2d0
[73366.839906]  [<ffffffff8d3a4503>] __es_insert_extent+0xb3/0x330
[73366.839985]  [<ffffffff8d3a573e>] ext4_es_insert_extent+0xee/0x280
[73366.840067]  [<ffffffff8d35a704>] ? ext4_map_blocks+0x2b4/0x5f0
[73366.840147]  [<ffffffff8d35a773>] ext4_map_blocks+0x323/0x5f0
[73366.840225]  [<ffffffff8d23dfda>] ? workingset_refault+0x10a/0x220
[73366.840314]  [<ffffffff8d3ad7d3>] ext4_mpage_readpages+0x413/0xa60
[73366.840397]  [<ffffffff8d201d96>] ? __page_cache_alloc+0x146/0x190
[73366.840487]  [<ffffffff8d358235>] ext4_readpages+0x35/0x40
[73366.840569]  [<ffffffff8d216d3f>] __do_page_cache_readahead+0x2bf/0x390
[73366.840651]  [<ffffffff8d216bea>] ? __do_page_cache_readahead+0x16a/0x390
[73366.840735]  [<ffffffff8d20622b>] filemap_fault+0x51b/0x790
[73366.840814]  [<ffffffff8d3639ce>] ? ext4_filemap_fault+0x2e/0x50
[73366.840896]  [<ffffffff8d3639d9>] ext4_filemap_fault+0x39/0x50
[73366.840976]  [<ffffffff8d241ca3>] __do_fault+0x83/0x1d0
[73366.841056]  [<ffffffff8d246642>] handle_mm_fault+0x11e2/0x17a0
[73366.841138]  [<ffffffff8d2454ba>] ? handle_mm_fault+0x5a/0x17a0
[73366.841220]  [<ffffffff8d06de16>] __do_page_fault+0x266/0x520
[73366.841300]  [<ffffffff8d06e1a8>] trace_do_page_fault+0x58/0x2a0
[73366.841382]  [<ffffffff8d067f3a>] do_async_page_fault+0x1a/0xa0
[73366.841464]  [<ffffffff8d918e28>] async_page_fault+0x28/0x30
[73366.842500] Mem-Info:
[73366.843149] active_anon:8677 inactive_anon:8798 isolated_anon:0
                 active_file:328 inactive_file:317 isolated_file:32
                 unevictable:0 dirty:0 writeback:2 unstable:0
                 slab_reclaimable:4968 slab_unreclaimable:9242
                 mapped:365 shmem:1 pagetables:2690 bounce:0
                 free:764 free_pcp:41 free_cma:0
[73366.846832] Node 0 active_anon:34708kB inactive_anon:35192kB 
active_file:1312kB inactive_file:1268kB unevictable:0kB 
isolated(anon):0kB isolated(file):128kB mapped:1460kB dirty:0kB 
writeback:8kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 
4kB writeback_tmp:0kB unstable:0kB pages_scanned:32 all_unreclaimable? no
[73366.848711] Node 0 DMA free:1468kB min:172kB low:212kB high:252kB 
active_anon:3216kB inactive_anon:3448kB active_file:40kB 
inactive_file:228kB unevictable:0kB writepending:0kB present:15992kB 
managed:15908kB mlocked:0kB slab_reclaimable:2064kB 
slab_unreclaimable:2960kB kernel_stack:100kB pagetables:1536kB 
bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[73366.850769] lowmem_reserve[]: 0 116 116 116 116
[73366.851479] Node 0 DMA32 free:1588kB min:1296kB low:1620kB 
high:1944kB active_anon:31464kB inactive_anon:31740kB active_file:1236kB 
inactive_file:1056kB unevictable:0kB writepending:0kB present:180080kB 
managed:139012kB mlocked:0kB slab_reclaimable:17808kB 
slab_unreclaimable:34008kB kernel_stack:1676kB pagetables:9224kB 
bounce:0kB free_pcp:164kB local_pcp:12kB free_cma:0kB
[73366.853757] lowmem_reserve[]: 0 0 0 0 0
[73366.854544] Node 0 DMA: 13*4kB (H) 13*8kB (H) 17*16kB (H) 12*32kB (H) 
8*64kB (H) 1*128kB (H) 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1452kB
[73366.856200] Node 0 DMA32: 70*4kB (UMH) 12*8kB (MH) 12*16kB (H) 2*32kB 
(H) 5*64kB (H) 5*128kB (H) 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 
1592kB
[73366.857955] Node 0 hugepages_total=0 hugepages_free=0 
hugepages_surp=0 hugepages_size=2048kB
[73366.857956] 2401 total pagecache pages
[73366.858829] 1741 pages in swap cache
[73366.859721] Swap cache stats: add 1230889, delete 1229148, find 
3509739/3747264
[73366.860616] Free swap  = 2059496kB
[73366.861500] Total swap = 2097148kB
[73366.862578] 49018 pages RAM
[73366.863560] 0 pages HighMem/MovableOnly
[73366.864531] 10288 pages reserved
[73366.865436] 0 pages cma reserved
[73366.866395] 0 pages hwpoisoned
[73366.867503] SLUB: Unable to allocate memory on node -1, 
gfp=0x2080020(GFP_ATOMIC)
[73366.868507]   cache: ext4_extent_status, object size: 40, buffer 
size: 40, default order: 0, min order: 0
[73366.869508]   node 0: slabs: 13, objs: 1326, free: 0
[96351.012045] dmcrypt_write: page allocation failure: order:0, 
mode:0x2280020(GFP_ATOMIC|__GFP_NOTRACK)
[96351.024364] CPU: 0 PID: 1593 Comm: dmcrypt_write Not tainted 
4.9.0-0.rc8.git2.1.fc26.x86_64 #1
[96351.027132] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), 
BIOS 1.9.3
[96351.029537]  ffffaa4ac025b508 ffffffff8d4774e3 ffffffff8dc7dd98 
0000000000000000
[96351.033023]  ffffaa4ac025b590 ffffffff8d20e6ea 0228002000000046 
ffffffff8dc7dd98
[96351.036214]  ffffaa4ac025b530 ffff9c3700000010 ffffaa4ac025b5a0 
ffffaa4ac025b550
[96351.039266] Call Trace:
[96351.041426]  [<ffffffff8d4774e3>] dump_stack+0x86/0xc3
[96351.044511]  [<ffffffff8d20e6ea>] warn_alloc+0x13a/0x170
[96351.046698]  [<ffffffff8d20e9e2>] __alloc_pages_slowpath+0x252/0xbb0
[96351.048852]  [<ffffffff8d20f74d>] __alloc_pages_nodemask+0x40d/0x4b0
[96351.052025]  [<ffffffff8d26db51>] alloc_pages_current+0xa1/0x1f0
[96351.053975]  [<ffffffff8d916f17>] ? _raw_spin_unlock+0x27/0x40
[96351.055066]  [<ffffffff8d278956>] new_slab+0x316/0x7c0
[96351.056134]  [<ffffffff8d0ed4c7>] ? sched_clock_cpu+0xa7/0xc0
[96351.057236]  [<ffffffff8d27ae8b>] ___slab_alloc+0x3fb/0x5c0
[96351.058287]  [<ffffffff8d10b042>] ? cpuacct_charge+0xf2/0x1f0
[96351.059374]  [<ffffffffc03a650d>] ? alloc_indirect.isra.11+0x1d/0x50 
[virtio_ring]
[96351.060439]  [<ffffffffc03a650d>] ? alloc_indirect.isra.11+0x1d/0x50 
[virtio_ring]
[96351.061484]  [<ffffffff8d27b0a1>] __slab_alloc+0x51/0x90
[96351.062505]  [<ffffffff8d27d141>] __kmalloc+0x251/0x320
[96351.063619]  [<ffffffffc03a650d>] ? alloc_indirect.isra.11+0x1d/0x50 
[virtio_ring]
[96351.064624]  [<ffffffffc03a650d>] alloc_indirect.isra.11+0x1d/0x50 
[virtio_ring]
[96351.065631]  [<ffffffffc03a7193>] virtqueue_add_sgs+0x1c3/0x4a0 
[virtio_ring]
[96351.066564]  [<ffffffff8d068475>] ? kvm_sched_clock_read+0x25/0x40
[96351.067504]  [<ffffffffc041e65c>] __virtblk_add_req+0xbc/0x220 
[virtio_blk]
[96351.068425]  [<ffffffff8d1312fd>] ? debug_lockdep_rcu_enabled+0x1d/0x20
[96351.069351]  [<ffffffffc041e935>] ? virtio_queue_rq+0x105/0x290 
[virtio_blk]
[96351.070229]  [<ffffffffc041e95d>] virtio_queue_rq+0x12d/0x290 
[virtio_blk]
[96351.071059]  [<ffffffff8d45015d>] __blk_mq_run_hw_queue+0x26d/0x3b0
[96351.071904]  [<ffffffff8d44fecd>] blk_mq_run_hw_queue+0xad/0xd0
[96351.072727]  [<ffffffff8d450fca>] blk_mq_insert_requests+0x24a/0x320
[96351.073607]  [<ffffffff8d452419>] blk_mq_flush_plug_list+0x139/0x160
[96351.074397]  [<ffffffff8d4451d6>] blk_flush_plug_list+0xb6/0x250
[96351.075111]  [<ffffffff8d44586c>] blk_finish_plug+0x2c/0x40
[96351.075869]  [<ffffffffc03adef0>] dmcrypt_write+0x210/0x220 [dm_crypt]
[96351.076613]  [<ffffffff8d0e6590>] ? wake_up_q+0x80/0x80
[96351.077376]  [<ffffffffc03adce0>] ? crypt_iv_essiv_dtr+0x70/0x70 
[dm_crypt]
[96351.078086]  [<ffffffffc03adce0>] ? crypt_iv_essiv_dtr+0x70/0x70 
[dm_crypt]
[96351.078892]  [<ffffffff8d0d82c2>] kthread+0x102/0x120
[96351.079635]  [<ffffffff8d111775>] ? trace_hardirqs_on_caller+0xf5/0x1b0
[96351.080403]  [<ffffffff8d0d81c0>] ? kthread_park+0x60/0x60
[96351.081115]  [<ffffffff8d917afa>] ret_from_fork+0x2a/0x40
[96351.081882] Mem-Info:
[96351.082616] active_anon:8390 inactive_anon:8478 isolated_anon:32
                 active_file:25 inactive_file:30 isolated_file:0
                 unevictable:0 dirty:0 writeback:151 unstable:0
                 slab_reclaimable:5304 slab_unreclaimable:9678
                 mapped:24 shmem:0 pagetables:3012 bounce:0
                 free:715 free_pcp:77 free_cma:0
[96351.086909] Node 0 active_anon:33560kB inactive_anon:33912kB 
active_file:100kB inactive_file:120kB unevictable:0kB 
isolated(anon):128kB isolated(file):0kB mapped:96kB dirty:0kB 
writeback:604kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 
0kB writeback_tmp:0kB unstable:0kB pages_scanned:395 all_unreclaimable? no
[96351.089052] Node 0 DMA free:1452kB min:172kB low:212kB high:252kB 
active_anon:3296kB inactive_anon:3768kB active_file:12kB 
inactive_file:0kB unevictable:0kB writepending:24kB present:15992kB 
managed:15908kB mlocked:0kB slab_reclaimable:2508kB 
slab_unreclaimable:3108kB kernel_stack:100kB pagetables:1024kB 
bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[96351.091383] lowmem_reserve[]: 0 116 116 116 116
[96351.092155] Node 0 DMA32 free:1408kB min:1296kB low:1620kB 
high:1944kB active_anon:30264kB inactive_anon:30140kB active_file:100kB 
inactive_file:124kB unevictable:0kB writepending:580kB present:180080kB 
managed:139012kB mlocked:0kB slab_reclaimable:18708kB 
slab_unreclaimable:35604kB kernel_stack:1820kB pagetables:11024kB 
bounce:0kB free_pcp:308kB local_pcp:152kB free_cma:0kB
[96351.094895] lowmem_reserve[]: 0 0 0 0 0
[96351.095803] Node 0 DMA: 13*4kB (H) 13*8kB (H) 17*16kB (H) 12*32kB (H) 
8*64kB (H) 1*128kB (H) 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1452kB
[96351.097708] Node 0 DMA32: 16*4kB (H) 6*8kB (H) 5*16kB (H) 8*32kB (H) 
5*64kB (H) 5*128kB (H) 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1408kB
[96351.099672] Node 0 hugepages_total=0 hugepages_free=0 
hugepages_surp=0 hugepages_size=2048kB
[96351.099673] 5020 total pagecache pages
[96351.100659] 4961 pages in swap cache
[96351.101635] Swap cache stats: add 1422746, delete 1417785, find 
4506321/4784232
[96351.102630] Free swap  = 1987544kB
[96351.103666] Total swap = 2097148kB
[96351.104730] 49018 pages RAM
[96351.105716] 0 pages HighMem/MovableOnly
[96351.106687] 10288 pages reserved
[96351.107642] 0 pages cma reserved
[96351.108584] 0 pages hwpoisoned
[96351.109523] SLUB: Unable to allocate memory on node -1, 
gfp=0x2080020(GFP_ATOMIC)
[96351.110479]   cache: kmalloc-256, object size: 256, buffer size: 256, 
default order: 0, min order: 0
[96351.111428]   node 0: slabs: 102, objs: 1632, free: 0
[96361.915109] swapper/0: page allocation failure: order:0, 
mode:0x2280020(GFP_ATOMIC|__GFP_NOTRACK)
[96361.916235] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 
4.9.0-0.rc8.git2.1.fc26.x86_64 #1
[96361.917276] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), 
BIOS 1.9.3
[96361.918313]  ffff9c3749e03628 ffffffff8d4774e3 ffffffff8dc7dd98 
0000000000000000
[96361.919381]  ffff9c3749e036b0 ffffffff8d20e6ea 0228002000000046 
ffffffff8dc7dd98
[96361.920511]  ffff9c3749e03650 ffff9c3700000010 ffff9c3749e036c0 
ffff9c3749e03670
[96361.921551] Call Trace:
[96361.922549]  <IRQ>
[96361.922566]  [<ffffffff8d4774e3>] dump_stack+0x86/0xc3
[96361.923684]  [<ffffffff8d20e6ea>] warn_alloc+0x13a/0x170
[96361.924735]  [<ffffffff8d20e9e2>] __alloc_pages_slowpath+0x252/0xbb0
[96361.925757]  [<ffffffff8d20f74d>] __alloc_pages_nodemask+0x40d/0x4b0
[96361.926772]  [<ffffffff8d26db51>] alloc_pages_current+0xa1/0x1f0
[96361.927844]  [<ffffffff8d278956>] new_slab+0x316/0x7c0
[96361.928884]  [<ffffffff8d27ae8b>] ___slab_alloc+0x3fb/0x5c0
[96361.929874]  [<ffffffff8d79b00b>] ? __alloc_skb+0x5b/0x1e0
[96361.930854]  [<ffffffff8d037de9>] ? sched_clock+0x9/0x10
[96361.931829]  [<ffffffff8d0ed4c7>] ? sched_clock_cpu+0xa7/0xc0
[96361.932796]  [<ffffffff8d79b00b>] ? __alloc_skb+0x5b/0x1e0
[96361.933778]  [<ffffffff8d27b0a1>] __slab_alloc+0x51/0x90
[96361.934764]  [<ffffffff8d27b7c2>] kmem_cache_alloc_node+0xb2/0x310
[96361.935713]  [<ffffffff8d79b00b>] ? __alloc_skb+0x5b/0x1e0
[96361.936637]  [<ffffffff8d79b00b>] __alloc_skb+0x5b/0x1e0
[96361.937534]  [<ffffffff8d7c2a9f>] __neigh_notify+0x3f/0xd0
[96361.938407]  [<ffffffff8d7c64b9>] neigh_update+0x379/0x8b0
[96361.939251]  [<ffffffff8d0b7000>] ? __local_bh_enable_ip+0x70/0xc0
[96361.940091]  [<ffffffff8d844702>] ? udp4_ufo_fragment+0x122/0x1a0
[96361.940915]  [<ffffffff8d845ee8>] arp_process+0x2e8/0x9f0
[96361.941708]  [<ffffffff8d846745>] arp_rcv+0x135/0x300
[96361.942473]  [<ffffffff8d111ed6>] ? __lock_acquire+0x346/0x1290
[96361.943211]  [<ffffffff8d7b42cd>] ? netif_receive_skb_internal+0x6d/0x200
[96361.943942]  [<ffffffff8d7b36da>] __netif_receive_skb_core+0x23a/0xd60
[96361.944664]  [<ffffffff8d7b42d3>] ? netif_receive_skb_internal+0x73/0x200
[96361.945360]  [<ffffffff8d7b4218>] __netif_receive_skb+0x18/0x60
[96361.946045]  [<ffffffff8d7b4320>] netif_receive_skb_internal+0xc0/0x200
[96361.946693]  [<ffffffff8d7b42d3>] ? netif_receive_skb_internal+0x73/0x200
[96361.947329]  [<ffffffff8d7b628c>] napi_gro_receive+0x13c/0x200
[96361.948002]  [<ffffffffc04cb667>] virtnet_receive+0x477/0x9a0 
[virtio_net]
[96361.948690]  [<ffffffffc04cbbad>] virtnet_poll+0x1d/0x80 [virtio_net]
[96361.949323]  [<ffffffff8d7b501e>] net_rx_action+0x23e/0x470
[96361.949994]  [<ffffffff8d91a8cd>] __do_softirq+0xcd/0x4b9
[96361.950639]  [<ffffffff8d0b7e98>] irq_exit+0x108/0x110
[96361.951275]  [<ffffffff8d91a49a>] do_IRQ+0x6a/0x120
[96361.951925]  [<ffffffff8d918256>] common_interrupt+0x96/0x96
[96361.952578]  <EOI>
[96361.952589]  [<ffffffff8d916676>] ? native_safe_halt+0x6/0x10
[96361.953245]  [<ffffffff8d916235>] default_idle+0x25/0x190
[96361.953912]  [<ffffffff8d03918f>] arch_cpu_idle+0xf/0x20
[96361.954562]  [<ffffffff8d916873>] default_idle_call+0x23/0x40
[96361.955192]  [<ffffffff8d104695>] cpu_startup_entry+0x1d5/0x250
[96361.955864]  [<ffffffff8d9066b5>] rest_init+0x135/0x140
[96361.956485]  [<ffffffff8e1ca01a>] start_kernel+0x48e/0x4af
[96361.957065]  [<ffffffff8e1c9120>] ? early_idt_handler_array+0x120/0x120
[96361.957644]  [<ffffffff8e1c92ca>] x86_64_start_reservations+0x24/0x26
[96361.958212]  [<ffffffff8e1c9419>] x86_64_start_kernel+0x14d/0x170
[96361.958880] SLUB: Unable to allocate memory on node -1, 
gfp=0x2080020(GFP_ATOMIC)
[96361.959482]   cache: kmalloc-256, object size: 256, buffer size: 256, 
default order: 0, min order: 0
[96361.960073]   node 0: slabs: 124, objs: 1984, free: 0
[99301.847630] kworker/dying (27373) used greatest stack depth: 8976 
bytes left

Ciao,

Gerhard


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
