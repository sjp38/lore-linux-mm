Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 55A556B0038
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 04:03:10 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id f21so168268721pgi.4
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 01:03:10 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id h12si9426456plk.250.2017.02.27.01.03.08
        for <linux-mm@kvack.org>;
        Mon, 27 Feb 2017 01:03:09 -0800 (PST)
Date: Mon, 27 Feb 2017 18:02:36 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: Still OOM problems with 4.9er/4.10er kernels
Message-ID: <20170227090236.GA2789@bbox>
References: <aa4a3217-f94c-0477-b573-796c84255d1e@wiesinger.com>
 <c4ddfc91-7c84-19ed-b69a-18403e7590f9@wiesinger.com>
 <b3d7a0f3-caa4-91f9-4148-b62cf5e23886@wiesinger.com>
 <20161209134025.GB4342@dhcp22.suse.cz>
 <a0bf765f-d5dd-7a51-1a6b-39cbda56bd58@wiesinger.com>
 <20161223025505.GA30876@bbox>
 <c2fe9c45-e25f-d3d6-7fe7-f91e353bc579@wiesinger.com>
 <20170104091120.GD25453@dhcp22.suse.cz>
 <82bce413-1bd7-7f66-1c3d-0d890bbaf6f1@wiesinger.com>
MIME-Version: 1.0
In-Reply-To: <82bce413-1bd7-7f66-1c3d-0d890bbaf6f1@wiesinger.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerhard Wiesinger <lists@wiesinger.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Sun, Feb 26, 2017 at 09:40:42AM +0100, Gerhard Wiesinger wrote:
> On 04.01.2017 10:11, Michal Hocko wrote:
> >>The VM stops working (e.g. not pingable) after around 8h (will be restarted
> >>automatically), happened serveral times.
> >>
> >>Had also further OOMs which I sent to Mincham.
> >Could you post them to the mailing list as well, please?
> 
> Still OOMs on dnf update procedure with kernel 4.10: 4.10.0-1.fc26.x86_64 as
> well on 4.9.9-200.fc25.x86_64
> 
> On 4.10er kernels:
> 
> Free swap  = 1137532kB
> 
> cat /etc/sysctl.d/* | grep ^vm
> vm.dirty_background_ratio = 3
> vm.dirty_ratio = 15
> vm.overcommit_memory = 2
> vm.overcommit_ratio = 80
> vm.swappiness=10
> 
> kernel: python invoked oom-killer:
> gfp_mask=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD), nodemask=0, order=0,
> oom_score_adj=0
> kernel: python cpuset=/ mems_allowed=0
> kernel: CPU: 1 PID: 813 Comm: python Not tainted 4.10.0-1.fc26.x86_64 #1
> kernel: Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.9.3
> 04/01/2014
> kernel: Call Trace:
> kernel:  dump_stack+0x63/0x84
> kernel:  dump_header+0x7b/0x1f6
> kernel:  ? do_try_to_free_pages+0x2c5/0x340
> kernel:  oom_kill_process+0x202/0x3d0
> kernel:  out_of_memory+0x2b7/0x4e0
> kernel:  __alloc_pages_slowpath+0x915/0xb80
> kernel:  __alloc_pages_nodemask+0x218/0x2d0
> kernel:  alloc_pages_current+0x93/0x150
> kernel:  __page_cache_alloc+0xcf/0x100
> kernel:  filemap_fault+0x39d/0x800
> kernel:  ? page_add_file_rmap+0xe5/0x200
> kernel:  ? filemap_map_pages+0x2e1/0x4e0
> kernel:  ext4_filemap_fault+0x36/0x50
> kernel:  __do_fault+0x21/0x110
> kernel:  handle_mm_fault+0xdd1/0x1410
> kernel:  ? swake_up+0x42/0x50
> kernel:  __do_page_fault+0x23f/0x4c0
> kernel:  trace_do_page_fault+0x41/0x120
> kernel:  do_async_page_fault+0x51/0xa0
> kernel:  async_page_fault+0x28/0x30
> kernel: RIP: 0033:0x7f0681ad6350
> kernel: RSP: 002b:00007ffcbdd238d8 EFLAGS: 00010246
> kernel: RAX: 00007f0681b0f960 RBX: 0000000000000000 RCX: 7fffffffffffffff
> kernel: RDX: 0000000000000000 RSI: 3ff0000000000000 RDI: 3ff0000000000000
> kernel: RBP: 00007f067461ab40 R08: 0000000000000000 R09: 3ff0000000000000
> kernel: R10: 0000556f1c6d8a80 R11: 0000000000000001 R12: 00007f0676d1a8d0
> kernel: R13: 0000000000000000 R14: 00007f06746168bc R15: 00007f0674385910
> kernel: Mem-Info:
> kernel: active_anon:37423 inactive_anon:37512 isolated_anon:0
>          active_file:462 inactive_file:603 isolated_file:0
>          unevictable:0 dirty:0 writeback:0 unstable:0
>          slab_reclaimable:3538 slab_unreclaimable:4818
>          mapped:859 shmem:9 pagetables:3370 bounce:0
>          free:1650 free_pcp:103 free_cma:0
> kernel: Node 0 active_anon:149380kB inactive_anon:149704kB
> active_file:1848kB inactive_file:3660kB unevictable:0kB isolated(anon):128kB
> isolated(file):0kB mapped:4580kB dirty:0kB writeback:380kB shmem:0kB
> shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 36kB writeback_tmp:0kB
> unstable:0kB pages_scanned:352 all_unreclaimable? no
> kernel: Node 0 DMA free:1484kB min:104kB low:128kB high:152kB
> active_anon:5660kB inactive_anon:6156kB active_file:56kB inactive_file:64kB
> unevictable:0kB writepending:0kB present:15992kB managed:15908kB mlocked:0kB
> slab_reclaimable:444kB slab_unreclaimable:1208kB kernel_stack:32kB
> pagetables:592kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
> kernel: lowmem_reserve[]: 0 327 327 327 327
> kernel: Node 0 DMA32 free:5012kB min:2264kB low:2828kB high:3392kB
> active_anon:143580kB inactive_anon:143300kB active_file:2576kB
> inactive_file:2560kB unevictable:0kB writepending:0kB present:376688kB
> managed:353968kB mlocked:0kB slab_reclaimable:13708kB
> slab_unreclaimable:18064kB kernel_stack:2352kB pagetables:12888kB bounce:0kB
> free_pcp:412kB local_pcp:88kB free_cma:0kB
> kernel: lowmem_reserve[]: 0 0 0 0 0
> kernel: Node 0 DMA: 70*4kB (UMEH) 20*8kB (UMEH) 13*16kB (MH) 5*32kB (H)
> 4*64kB (H) 2*128kB (H) 1*256kB (H) 0*512kB 0*1024kB 0*2048kB 0*4096kB =
> 1576kB
> kernel: Node 0 DMA32: 1134*4kB (UMEH) 25*8kB (UMEH) 13*16kB (MH) 7*32kB (H)
> 3*64kB (H) 0*128kB 1*256kB (H) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 5616kB
 
Althogh DMA32 zone has enough free memory, free memory includes H pageblock
which is reserved memory for high-order atomic allocation. That might be
a reason you cannot succeed watermark check for the allocation.

I tried to solve the issue in 4.9 time to use up the reserved memory before
the OOM and merged into 4.10 but I think there is a hole so could you apply
this patch on top of your 4.10? (To be clear, cannot apply it to 4.9)
