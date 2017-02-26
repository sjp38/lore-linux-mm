From: Gerhard Wiesinger <lists@wiesinger.com>
Subject: Re: Still OOM problems with 4.9er/4.10er kernels
Date: Sun, 26 Feb 2017 09:40:42 +0100
Message-ID: <82bce413-1bd7-7f66-1c3d-0d890bbaf6f1@wiesinger.com>
References: <aa4a3217-f94c-0477-b573-796c84255d1e@wiesinger.com>
 <c4ddfc91-7c84-19ed-b69a-18403e7590f9@wiesinger.com>
 <b3d7a0f3-caa4-91f9-4148-b62cf5e23886@wiesinger.com>
 <20161209134025.GB4342@dhcp22.suse.cz>
 <a0bf765f-d5dd-7a51-1a6b-39cbda56bd58@wiesinger.com>
 <20161223025505.GA30876@bbox>
 <c2fe9c45-e25f-d3d6-7fe7-f91e353bc579@wiesinger.com>
 <20170104091120.GD25453@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170104091120.GD25453@dhcp22.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
To: Michal Hocko <mhocko@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>
List-Id: linux-mm.kvack.org

On 04.01.2017 10:11, Michal Hocko wrote:
>> The VM stops working (e.g. not pingable) after around 8h (will be restarted
>> automatically), happened serveral times.
>>
>> Had also further OOMs which I sent to Mincham.
> Could you post them to the mailing list as well, please?

Still OOMs on dnf update procedure with kernel 4.10: 
4.10.0-1.fc26.x86_64 as well on 4.9.9-200.fc25.x86_64

On 4.10er kernels:

Free swap  = 1137532kB

cat /etc/sysctl.d/* | grep ^vm
vm.dirty_background_ratio = 3
vm.dirty_ratio = 15
vm.overcommit_memory = 2
vm.overcommit_ratio = 80
vm.swappiness=10

kernel: python invoked oom-killer: 
gfp_mask=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD), nodemask=0, 
order=0, oom_score_adj=0
kernel: python cpuset=/ mems_allowed=0
kernel: CPU: 1 PID: 813 Comm: python Not tainted 4.10.0-1.fc26.x86_64 #1
kernel: Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 
1.9.3 04/01/2014
kernel: Call Trace:
kernel:  dump_stack+0x63/0x84
kernel:  dump_header+0x7b/0x1f6
kernel:  ? do_try_to_free_pages+0x2c5/0x340
kernel:  oom_kill_process+0x202/0x3d0
kernel:  out_of_memory+0x2b7/0x4e0
kernel:  __alloc_pages_slowpath+0x915/0xb80
kernel:  __alloc_pages_nodemask+0x218/0x2d0
kernel:  alloc_pages_current+0x93/0x150
kernel:  __page_cache_alloc+0xcf/0x100
kernel:  filemap_fault+0x39d/0x800
kernel:  ? page_add_file_rmap+0xe5/0x200
kernel:  ? filemap_map_pages+0x2e1/0x4e0
kernel:  ext4_filemap_fault+0x36/0x50
kernel:  __do_fault+0x21/0x110
kernel:  handle_mm_fault+0xdd1/0x1410
kernel:  ? swake_up+0x42/0x50
kernel:  __do_page_fault+0x23f/0x4c0
kernel:  trace_do_page_fault+0x41/0x120
kernel:  do_async_page_fault+0x51/0xa0
kernel:  async_page_fault+0x28/0x30
kernel: RIP: 0033:0x7f0681ad6350
kernel: RSP: 002b:00007ffcbdd238d8 EFLAGS: 00010246
kernel: RAX: 00007f0681b0f960 RBX: 0000000000000000 RCX: 7fffffffffffffff
kernel: RDX: 0000000000000000 RSI: 3ff0000000000000 RDI: 3ff0000000000000
kernel: RBP: 00007f067461ab40 R08: 0000000000000000 R09: 3ff0000000000000
kernel: R10: 0000556f1c6d8a80 R11: 0000000000000001 R12: 00007f0676d1a8d0
kernel: R13: 0000000000000000 R14: 00007f06746168bc R15: 00007f0674385910
kernel: Mem-Info:
kernel: active_anon:37423 inactive_anon:37512 isolated_anon:0
          active_file:462 inactive_file:603 isolated_file:0
          unevictable:0 dirty:0 writeback:0 unstable:0
          slab_reclaimable:3538 slab_unreclaimable:4818
          mapped:859 shmem:9 pagetables:3370 bounce:0
          free:1650 free_pcp:103 free_cma:0
kernel: Node 0 active_anon:149380kB inactive_anon:149704kB 
active_file:1848kB inactive_file:3660kB unevictable:0kB 
isolated(anon):128kB isolated(file):0kB mapped:4580kB dirty:0kB 
writeback:380kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 
36kB writeback_tmp:0kB unstable:0kB pages_scanned:352 all_unreclaimable? no
kernel: Node 0 DMA free:1484kB min:104kB low:128kB high:152kB 
active_anon:5660kB inactive_anon:6156kB active_file:56kB 
inactive_file:64kB unevictable:0kB writepending:0kB present:15992kB 
managed:15908kB mlocked:0kB slab_reclaimable:444kB 
slab_unreclaimable:1208kB kernel_stack:32kB pagetables:592kB bounce:0kB 
free_pcp:0kB local_pcp:0kB free_cma:0kB
kernel: lowmem_reserve[]: 0 327 327 327 327
kernel: Node 0 DMA32 free:5012kB min:2264kB low:2828kB high:3392kB 
active_anon:143580kB inactive_anon:143300kB active_file:2576kB 
inactive_file:2560kB unevictable:0kB writepending:0kB present:376688kB 
managed:353968kB mlocked:0kB slab_reclaimable:13708kB 
slab_unreclaimable:18064kB kernel_stack:2352kB pagetables:12888kB 
bounce:0kB free_pcp:412kB local_pcp:88kB free_cma:0kB
kernel: lowmem_reserve[]: 0 0 0 0 0
kernel: Node 0 DMA: 70*4kB (UMEH) 20*8kB (UMEH) 13*16kB (MH) 5*32kB (H) 
4*64kB (H) 2*128kB (H) 1*256kB (H) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 
1576kB
kernel: Node 0 DMA32: 1134*4kB (UMEH) 25*8kB (UMEH) 13*16kB (MH) 7*32kB 
(H) 3*64kB (H) 0*128kB 1*256kB (H) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 
5616kB
kernel: Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 
hugepages_size=2048kB
kernel: 6561 total pagecache pages
kernel: 5240 pages in swap cache
kernel: Swap cache stats: add 100078658, delete 100073419, find 
199458343/238460223
kernel: Free swap  = 1137532kB
kernel: Total swap = 2064380kB
kernel: 98170 pages RAM
kernel: 0 pages HighMem/MovableOnly
kernel: 5701 pages reserved
kernel: 0 pages cma reserved
kernel: 0 pages hwpoisoned
kernel: Out of memory: Kill process 11968 (clamscan) score 170 or 
sacrifice child
kernel: Killed process 11968 (clamscan) total-vm:538120kB, 
anon-rss:182220kB, file-rss:464kB, shmem-rss:0kB

On 4.9er kernels:

Free swap  = 1826688kB

cat /etc/sysctl.d/* | grep ^vm
vm.dirty_background_ratio=3
vm.dirty_ratio=15
vm.overcommit_memory=2
vm.overcommit_ratio=80
vm.swappiness=10

kernel: dnf invoked oom-killer: 
gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=0, 
order=0, oom_score_adj=0
kernel: dnf cpuset=/ mems_allowed=0
kernel: CPU: 0 PID: 20049 Comm: dnf Not tainted 4.9.9-200.fc25.x86_64 #1
kernel: Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 
1.9.3 04/01/2014
kernel:  ffffa764434d7ac0 ffffffff933f467d ffffa764434d7c90 ffff9569999057c0
kernel:  ffffa764434d7b38 ffffffff932555c1 0000000000000000 0000000000000000
kernel:  ffffffffc02b2afa 00000000ffffffff 0000000000000000 ffffa764434d7b28
kernel: Call Trace:
kernel:  [<ffffffff933f467d>] dump_stack+0x63/0x86
kernel:  [<ffffffff932555c1>] dump_header+0x7b/0x1f6
kernel:  [<ffffffffc02b2afa>] ? virtballoon_oom_notify+0x2a/0x80 
[virtio_balloon]
kernel:  [<ffffffff931c711f>] oom_kill_process+0x1ff/0x3d0
kernel:  [<ffffffff931c7623>] out_of_memory+0x143/0x4e0
kernel:  [<ffffffff931cd3cd>] __alloc_pages_slowpath+0xb2d/0xc40
kernel:  [<ffffffff931cd736>] __alloc_pages_nodemask+0x256/0x2c0
kernel:  [<ffffffff9322567b>] alloc_pages_vma+0xab/0x290
kernel:  [<ffffffff931fe2ed>] handle_mm_fault+0x13bd/0x1610
kernel:  [<ffffffff9306283e>] __do_page_fault+0x23e/0x4e0
kernel:  [<ffffffff93062ba1>] trace_do_page_fault+0x41/0x120
kernel:  [<ffffffff9305caba>] do_async_page_fault+0x1a/0xa0
kernel:  [<ffffffff9381f3b8>] async_page_fault+0x28/0x30
kernel: Mem-Info:
kernel: active_anon:31057 inactive_anon:30347 isolated_anon:0
          active_file:20333 inactive_file:25749 isolated_file:32
          unevictable:0 dirty:1444 writeback:0 unstable:0
          slab_reclaimable:4537 slab_unreclaimable:5448
          mapped:15224 shmem:120 pagetables:2537 bounce:0
          free:1133 free_pcp:196 free_cma:0
kernel: Node 0 active_anon:122692kB inactive_anon:122948kB 
active_file:81332kB inactive_file:102996kB unevictable:0kB 
isolated(anon):0kB isolated(file):128kB mapped:60896kB dirty:5776kB 
writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 
480kB writeback_tmp:0kB unstable:0kB pages_scanned:962974 
all_unreclaimable? yes
kernel: Node 0 DMA free:1892kB min:92kB low:112kB high:132kB 
active_anon:544kB inactive_anon:10872kB active_file:16kB 
inactive_file:996kB unevictable:0kB writepending:1128kB present:15992kB 
managed:15908kB mlocked:0kB slab_reclaimable:488kB 
slab_unreclaimable:388kB kernel_stack:0kB pagetables:24kB bounce:0kB 
free_pcp:0kB local_pcp:0kB free_cma:0kB
kernel: lowmem_reserve[]: 0 451 451 451 451
kernel: Node 0 DMA32 free:3356kB min:2668kB low:3332kB high:3996kB 
active_anon:122148kB inactive_anon:112068kB active_file:81324kB 
inactive_file:101972kB unevictable:0kB writepending:4648kB 
present:507760kB managed:484384kB mlocked:0kB slab_reclaimable:17660kB 
slab_unreclaimable:21404kB kernel_stack:2432kB pagetables:10124kB 
bounce:0kB free_pcp:120kB local_pcp:0kB free_cma:0kB
kernel: lowmem_reserve[]: 0 0 0 0 0
kernel: Node 0 DMA: 81*4kB (UEH) 26*8kB (UMEH) 15*16kB (UH) 7*32kB (H) 
8*64kB (H) 3*128kB (H) 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1892kB
kernel: Node 0 DMA32: 375*4kB (UMH) 18*8kB (MH) 7*16kB (MH) 6*32kB (MH) 
6*64kB (H) 4*128kB (H) 2*256kB (H) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 
3356kB
kernel: Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 
hugepages_size=2048kB
kernel: 49304 total pagecache pages
kernel: 3085 pages in swap cache
kernel: Swap cache stats: add 129095, delete 126010, find 24611247/24627536
kernel: Free swap  = 1826688kB
kernel: Total swap = 2064380kB
kernel: 130938 pages RAM
kernel: 0 pages HighMem/MovableOnly
kernel: 5865 pages reserved
kernel: 0 pages cma reserved
kernel: 0 pages hwpoisoned
kernel: Out of memory: Kill process 995 (named) score 87 or sacrifice child
kernel: Killed process 995 (named) total-vm:399260kB, anon-rss:86516kB, 
file-rss:1288kB, shmem-rss:0kB
kernel: oom_reaper: reaped process 995 (named), now anon-rss:0kB, 
file-rss:0kB, shmem-rss:0kB

Should be very easy to reproduce with a low mem VM (e.g. 192MB) under 
KVM with ext4 and Fedora 25 and some memory load and updating the VM.

Any further progress?

Thnx.

Ciao,

Gerhard
