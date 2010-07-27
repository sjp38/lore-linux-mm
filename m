Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BE1F4600365
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 06:40:58 -0400 (EDT)
Received: by pvc30 with SMTP id 30so460948pvc.14
        for <linux-mm@kvack.org>; Tue, 27 Jul 2010 03:40:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTikjJ0giM+MpzNu3e0NQN=JLMviPT8UPHdZqGGpz@mail.gmail.com>
References: <20100727134431.2F11.A69D9226@jp.fujitsu.com> <AANLkTimdLbwvRNU09s+LfauREBaxyXBUE5jSmwnpCj8e@mail.gmail.com>
	<20100727150138.2F20.A69D9226@jp.fujitsu.com> <AANLkTikjJ0giM+MpzNu3e0NQN=JLMviPT8UPHdZqGGpz@mail.gmail.com>
From: dave b <db.pub.mail@gmail.com>
Date: Tue, 27 Jul 2010 20:40:32 +1000
Message-ID: <AANLkTinT_W4Zfg8xcpKXMpqTAomdVBdHve7VqamdSr4o@mail.gmail.com>
Subject: Re: PROBLEM: oom killer and swap weirdness on 2.6.3* kernels
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 27 July 2010 18:09, dave b <db.pub.mail@gmail.com> wrote:
> On 27 July 2010 16:09, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
>>> > Do you mean the issue will be gone if disabling intel graphics?
>>> It may be a general issue or it could just be specific :)
>
> I will try with the latest ubuntu and report how that goes (that will
> be using fairly new xorg etc.) it is likely to be hidden issue just
> with the intel graphics driver. However, my concern is that it isn't -
> and it is about how shared graphics memory is handled :)


Ok my desktop still stalled and no oom killer was invoked when I added
swap to a live-cd of 10.04 amd64.

*Without* *swap* *on* - the oom killer was invoked - here is a copy of it.

[  298.180542] Xorg invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=0
[  298.180553] Xorg cpuset=/ mems_allowed=0
[  298.180560] Pid: 3808, comm: Xorg Not tainted 2.6.32-21-generic #32-Ubuntu
[  298.180564] Call Trace:
[  298.180583]  [<ffffffff810b37cd>] ? cpuset_print_task_mems_allowed+0x9d/0xb0
[  298.180595]  [<ffffffff810f64f4>] oom_kill_process+0xd4/0x2f0
[  298.180603]  [<ffffffff810f6ab0>] ? select_bad_process+0xd0/0x110
[  298.180609]  [<ffffffff810f6b48>] __out_of_memory+0x58/0xc0
[  298.180616]  [<ffffffff810f6cde>] out_of_memory+0x12e/0x1a0
[  298.180626]  [<ffffffff81540c9e>] ? _spin_lock+0xe/0x20
[  298.180633]  [<ffffffff810f9d21>] __alloc_pages_slowpath+0x511/0x580
[  298.180641]  [<ffffffff810f9eee>] __alloc_pages_nodemask+0x15e/0x1a0
[  298.180650]  [<ffffffff8112ca57>] alloc_pages_current+0x87/0xd0
[  298.180657]  [<ffffffff810f8e0e>] __get_free_pages+0xe/0x50
[  298.180666]  [<ffffffff81154994>] __pollwait+0xb4/0xf0
[  298.180673]  [<ffffffff814e09a5>] unix_poll+0x25/0xc0
[  298.180682]  [<ffffffff81449bea>] sock_poll+0x1a/0x20
[  298.180688]  [<ffffffff811545b2>] do_select+0x3a2/0x6d0
[  298.180696]  [<ffffffff811548e0>] ? __pollwait+0x0/0xf0
[  298.180702]  [<ffffffff811549d0>] ? pollwake+0x0/0x60
[  298.180708]  [<ffffffff811549d0>] ? pollwake+0x0/0x60
[  298.180714]  [<ffffffff811549d0>] ? pollwake+0x0/0x60
[  298.180721]  [<ffffffff811549d0>] ? pollwake+0x0/0x60
[  298.180727]  [<ffffffff811549d0>] ? pollwake+0x0/0x60
[  298.180732]  [<ffffffff811549d0>] ? pollwake+0x0/0x60
[  298.180737]  [<ffffffff811549d0>] ? pollwake+0x0/0x60
[  298.180741]  [<ffffffff811549d0>] ? pollwake+0x0/0x60
[  298.180745]  [<ffffffff811549d0>] ? pollwake+0x0/0x60
[  298.180749]  [<ffffffff811550ba>] core_sys_select+0x18a/0x2c0
[  298.180777]  [<ffffffffa001eced>] ? drm_ioctl+0x13d/0x480 [drm]
[  298.180784]  [<ffffffff81085320>] ? autoremove_wake_function+0x0/0x40
[  298.180790]  [<ffffffff810397a9>] ? default_spin_lock_flags+0x9/0x10
[  298.180795]  [<ffffffff81540bbf>] ? _spin_lock_irqsave+0x2f/0x40
[  298.180800]  [<ffffffff81019e89>] ? read_tsc+0x9/0x20
[  298.180805]  [<ffffffff8108f9c9>] ? ktime_get_ts+0xa9/0xe0
[  298.180810]  [<ffffffff81155447>] sys_select+0x47/0x110
[  298.180816]  [<ffffffff810131b2>] system_call_fastpath+0x16/0x1b
[  298.180819] Mem-Info:
[  298.180822] Node 0 DMA per-cpu:
[  298.180827] CPU    0: hi:    0, btch:   1 usd:   0
[  298.180830] CPU    1: hi:    0, btch:   1 usd:   0
[  298.180832] Node 0 DMA32 per-cpu:
[  298.180837] CPU    0: hi:  186, btch:  31 usd:  60
[  298.180839] CPU    1: hi:  186, btch:  31 usd: 137
[  298.180845] active_anon:374344 inactive_anon:81753 isolated_anon:0
[  298.180847]  active_file:7038 inactive_file:7089 isolated_file:0
[  298.180848]  unevictable:0 dirty:0 writeback:0 unstable:0
[  298.180849]  free:3399 slab_reclaimable:4226 slab_unreclaimable:4383
[  298.180851]  mapped:13010 shmem:45284 pagetables:5496 bounce:0
[  298.180854] Node 0 DMA free:7920kB min:40kB low:48kB high:60kB
active_anon:3880kB inactive_anon:4096kB active_file:0kB
inactive_file:0kB unevictable:0kB isolated(anon):0kB
isolated(file):0kB present:15348kB mlocked:0kB dirty:0kB writeback:0kB
mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:8kB
kernel_stack:0kB pagetables:16kB unstable:0kB bounce:0kB
writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[  298.180866] lowmem_reserve[]: 0 1971 1971 1971
[  298.180871] Node 0 DMA32 free:5676kB min:5660kB low:7072kB
high:8488kB active_anon:1493496kB inactive_anon:322916kB
active_file:28152kB inactive_file:28356kB unevictable:0kB
isolated(anon):0kB isolated(file):0kB present:2019172kB mlocked:0kB
dirty:0kB writeback:0kB mapped:52040kB shmem:181136kB
slab_reclaimable:16904kB slab_unreclaimable:17524kB
kernel_stack:2096kB pagetables:21968kB unstable:0kB bounce:0kB
writeback_tmp:0kB pages_scanned:41088 all_unreclaimable? no
[  298.180884] lowmem_reserve[]: 0 0 0 0
[  298.180889] Node 0 DMA: 4*4kB 2*8kB 1*16kB 2*32kB 2*64kB 2*128kB
1*256kB 2*512kB 2*1024kB 2*2048kB 0*4096kB = 7920kB
[  298.180904] Node 0 DMA32: 397*4kB 1*8kB 1*16kB 1*32kB 1*64kB
1*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 5676kB
[  298.180918] 59413 total pagecache pages
[  298.180920] 0 pages in swap cache
[  298.180923] Swap cache stats: add 0, delete 0, find 0/0
[  298.180925] Free swap  = 0kB
[  298.180927] Total swap = 0kB
[  298.188124] 515887 pages RAM
[  298.188127] 9764 pages reserved
[  298.188129] 108553 pages shared
[  298.188131] 467319 pages non-shared
[  298.188136] Out of memory: kill process 3821 (gnome-session) score
503983 or a child
[  298.188141] Killed process 3855 (ssh-agent)
[  300.280284] gnome-terminal invoked oom-killer: gfp_mask=0xd0,
order=0, oom_adj=0
[  300.280293] gnome-terminal cpuset=/ mems_allowed=0
[  300.280300] Pid: 4081, comm: gnome-terminal Not tainted
2.6.32-21-generic #32-Ubuntu
[  300.280304] Call Trace:
[  300.280322]  [<ffffffff810b37cd>] ? cpuset_print_task_mems_allowed+0x9d/0xb0
[  300.280331]  [<ffffffff810f64f4>] oom_kill_process+0xd4/0x2f0
[  300.280338]  [<ffffffff810f6ab0>] ? select_bad_process+0xd0/0x110
[  300.280345]  [<ffffffff810f6b48>] __out_of_memory+0x58/0xc0
[  300.280351]  [<ffffffff810f6cde>] out_of_memory+0x12e/0x1a0
[  300.280360]  [<ffffffff81540c9e>] ? _spin_lock+0xe/0x20
[  300.280367]  [<ffffffff810f9d21>] __alloc_pages_slowpath+0x511/0x580
[  300.280375]  [<ffffffff810f9eee>] __alloc_pages_nodemask+0x15e/0x1a0
[  300.280386]  [<ffffffff8112ca57>] alloc_pages_current+0x87/0xd0
[  300.280393]  [<ffffffff810f8e0e>] __get_free_pages+0xe/0x50
[  300.280401]  [<ffffffff81154994>] __pollwait+0xb4/0xf0
[  300.280408]  [<ffffffff814e09a5>] unix_poll+0x25/0xc0
[  300.280416]  [<ffffffff81449bea>] sock_poll+0x1a/0x20
[  300.280423]  [<ffffffff81153f95>] do_poll+0x115/0x2c0
[  300.280430]  [<ffffffff81154b85>] do_sys_poll+0x155/0x210
[  300.280436]  [<ffffffff811548e0>] ? __pollwait+0x0/0xf0
[  300.280443]  [<ffffffff811549d0>] ? pollwake+0x0/0x60
[  300.280449]  [<ffffffff811549d0>] ? pollwake+0x0/0x60
[  300.280456]  [<ffffffff811549d0>] ? pollwake+0x0/0x60
[  300.280462]  [<ffffffff811549d0>] ? pollwake+0x0/0x60
[  300.280468]  [<ffffffff811549d0>] ? pollwake+0x0/0x60
[  300.280474]  [<ffffffff811549d0>] ? pollwake+0x0/0x60
[  300.280480]  [<ffffffff811549d0>] ? pollwake+0x0/0x60
[  300.280487]  [<ffffffff811549d0>] ? pollwake+0x0/0x60
[  300.280493]  [<ffffffff811549d0>] ? pollwake+0x0/0x60
[  300.280502]  [<ffffffff8133111e>] ? tty_ldisc_deref+0xe/0x10
[  300.280510]  [<ffffffff81019e89>] ? read_tsc+0x9/0x20
[  300.280518]  [<ffffffff8108f9c9>] ? ktime_get_ts+0xa9/0xe0
[  300.280525]  [<ffffffff81153e0d>] ? poll_select_set_timeout+0x8d/0xa0
[  300.280532]  [<ffffffff81154e3c>] sys_poll+0x7c/0x110
[  300.280541]  [<ffffffff810131b2>] system_call_fastpath+0x16/0x1b
[  300.280545] Mem-Info:
[  300.280549] Node 0 DMA per-cpu:
[  300.280554] CPU    0: hi:    0, btch:   1 usd:   0
[  300.280558] CPU    1: hi:    0, btch:   1 usd:   0
[  300.280561] Node 0 DMA32 per-cpu:
[  300.280566] CPU    0: hi:  186, btch:  31 usd:  31
[  300.280570] CPU    1: hi:  186, btch:  31 usd: 138
[  300.280579] active_anon:373779 inactive_anon:82443 isolated_anon:0
[  300.280581]  active_file:7002 inactive_file:7034 isolated_file:64
[  300.280583]  unevictable:0 dirty:0 writeback:0 unstable:0
[  300.280585]  free:3370 slab_reclaimable:4219 slab_unreclaimable:4383
[  300.280587]  mapped:12988 shmem:44524 pagetables:5489 bounce:0
[  300.280592] Node 0 DMA free:7920kB min:40kB low:48kB high:60kB
active_anon:3880kB inactive_anon:4096kB active_file:0kB
inactive_file:0kB unevictable:0kB isolated(anon):0kB
isolated(file):0kB present:15348kB mlocked:0kB dirty:0kB writeback:0kB
mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:8kB
kernel_stack:0kB pagetables:16kB unstable:0kB bounce:0kB
writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[  300.280611] lowmem_reserve[]: 0 1971 1971 1971
[  300.280619] Node 0 DMA32 free:5560kB min:5660kB low:7072kB
high:8488kB active_anon:1491236kB inactive_anon:325676kB
active_file:28008kB inactive_file:28136kB unevictable:0kB
isolated(anon):0kB isolated(file):256kB present:2019172kB mlocked:0kB
dirty:0kB writeback:0kB mapped:51952kB shmem:178096kB
slab_reclaimable:16876kB slab_unreclaimable:17524kB
kernel_stack:2096kB pagetables:21940kB unstable:0kB bounce:0kB
writeback_tmp:0kB pages_scanned:58305 all_unreclaimable? no
[  300.280639] lowmem_reserve[]: 0 0 0 0
[  300.280647] Node 0 DMA: 4*4kB 2*8kB 1*16kB 2*32kB 2*64kB 2*128kB
1*256kB 2*512kB 2*1024kB 2*2048kB 0*4096kB = 7920kB
[  300.280668] Node 0 DMA32: 366*4kB 0*8kB 0*16kB 0*32kB 0*64kB
0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 1*4096kB = 5560kB
[  300.280687] 58623 total pagecache pages
[  300.280691] 0 pages in swap cache
[  300.280695] Swap cache stats: add 0, delete 0, find 0/0
[  300.280698] Free swap  = 0kB
[  300.280700] Total swap = 0kB
[  300.289576] 515887 pages RAM
[  300.289581] 9764 pages reserved
[  300.289583] 107753 pages shared
[  300.289585] 468177 pages non-shared
[  300.289590] Out of memory: kill process 3821 (gnome-session) score
502491 or a child
[  300.289595] Killed process 3883 (bluetooth-apple)
[  302.180340] a.out invoked oom-killer: gfp_mask=0x280da, order=0, oom_adj=0
[  302.180347] a.out cpuset=/ mems_allowed=0
[  302.180352] Pid: 4210, comm: a.out Not tainted 2.6.32-21-generic #32-Ubuntu
[  302.180355] Call Trace:
[  302.180367]  [<ffffffff810b37cd>] ? cpuset_print_task_mems_allowed+0x9d/0xb0
[  302.180374]  [<ffffffff810f64f4>] oom_kill_process+0xd4/0x2f0
[  302.180379]  [<ffffffff810f6ab0>] ? select_bad_process+0xd0/0x110
[  302.180383]  [<ffffffff810f6b48>] __out_of_memory+0x58/0xc0
[  302.180388]  [<ffffffff810f6cde>] out_of_memory+0x12e/0x1a0
[  302.180395]  [<ffffffff81540c9e>] ? _spin_lock+0xe/0x20
[  302.180399]  [<ffffffff810f9d21>] __alloc_pages_slowpath+0x511/0x580
[  302.180405]  [<ffffffff810f9eee>] __alloc_pages_nodemask+0x15e/0x1a0
[  302.180411]  [<ffffffff8112cb12>] alloc_page_vma+0x72/0xf0
[  302.180416]  [<ffffffff810fe741>] ? lru_cache_add_lru+0x21/0x40
[  302.180422]  [<ffffffff81110580>] do_anonymous_page+0x100/0x260
[  302.180426]  [<ffffffff811150ff>] handle_mm_fault+0x31f/0x3c0
[  302.180433]  [<ffffffff810397a9>] ? default_spin_lock_flags+0x9/0x10
[  302.180439]  [<ffffffff8154380a>] do_page_fault+0x12a/0x3b0
[  302.180443]  [<ffffffff81541165>] page_fault+0x25/0x30
[  302.180447] Mem-Info:
[  302.180450] Node 0 DMA per-cpu:
[  302.180453] CPU    0: hi:    0, btch:   1 usd:   0
[  302.180456] CPU    1: hi:    0, btch:   1 usd:   0
[  302.180458] Node 0 DMA32 per-cpu:
[  302.180462] CPU    0: hi:  186, btch:  31 usd:  68
[  302.180464] CPU    1: hi:  186, btch:  31 usd: 158
[  302.180470] active_anon:374176 inactive_anon:82789 isolated_anon:0
[  302.180472]  active_file:6734 inactive_file:6846 isolated_file:31
[  302.180473]  unevictable:0 dirty:0 writeback:0 unstable:0
[  302.180474]  free:3413 slab_reclaimable:3970 slab_unreclaimable:4374
[  302.180476]  mapped:12935 shmem:44505 pagetables:5405 bounce:0
[  302.180479] Node 0 DMA free:7920kB min:40kB low:48kB high:60kB
active_anon:3880kB inactive_anon:4096kB active_file:0kB
inactive_file:0kB unevictable:0kB isolated(anon):0kB
isolated(file):0kB present:15348kB mlocked:0kB dirty:0kB writeback:0kB
mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:8kB
kernel_stack:0kB pagetables:16kB unstable:0kB bounce:0kB
writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[  302.180491] lowmem_reserve[]: 0 1971 1971 1971
[  302.180497] Node 0 DMA32 free:5732kB min:5660kB low:7072kB
high:8488kB active_anon:1492824kB inactive_anon:327060kB
active_file:26936kB inactive_file:27384kB unevictable:0kB
isolated(anon):0kB isolated(file):124kB present:2019172kB mlocked:0kB
dirty:0kB writeback:0kB mapped:51740kB shmem:178020kB
slab_reclaimable:15880kB slab_unreclaimable:17488kB
kernel_stack:2080kB pagetables:21604kB unstable:0kB bounce:0kB
writeback_tmp:0kB pages_scanned:25314 all_unreclaimable? no
[  302.180510] lowmem_reserve[]: 0 0 0 0
[  302.180515] Node 0 DMA: 4*4kB 2*8kB 1*16kB 2*32kB 2*64kB 2*128kB
1*256kB 2*512kB 2*1024kB 2*2048kB 0*4096kB = 7920kB
[  302.180529] Node 0 DMA32: 399*4kB 5*8kB 0*16kB 0*32kB 0*64kB
0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 1*4096kB = 5732kB
[  302.180542] 58114 total pagecache pages
[  302.180544] 0 pages in swap cache
[  302.180547] Swap cache stats: add 0, delete 0, find 0/0
[  302.180549] Free swap  = 0kB
[  302.180551] Total swap = 0kB
[  302.187756] 515887 pages RAM
[  302.187760] 9764 pages reserved
[  302.187762] 105575 pages shared
[  302.187764] 468594 pages non-shared
[  302.187768] Out of memory: kill process 3821 (gnome-session) score
409517 or a child
[  302.187774] Killed process 3886 (nm-applet)
[  303.112722] a.out invoked oom-killer: gfp_mask=0x280da, order=0, oom_adj=0
[  303.112729] a.out cpuset=/ mems_allowed=0
[  303.112734] Pid: 4210, comm: a.out Not tainted 2.6.32-21-generic #32-Ubuntu
[  303.112737] Call Trace:
[  303.112749]  [<ffffffff810b37cd>] ? cpuset_print_task_mems_allowed+0x9d/0xb0
[  303.112756]  [<ffffffff810f64f4>] oom_kill_process+0xd4/0x2f0
[  303.112760]  [<ffffffff810f6ab0>] ? select_bad_process+0xd0/0x110
[  303.112765]  [<ffffffff810f6b48>] __out_of_memory+0x58/0xc0
[  303.112769]  [<ffffffff810f6cde>] out_of_memory+0x12e/0x1a0
[  303.112776]  [<ffffffff81540c9e>] ? _spin_lock+0xe/0x20
[  303.112780]  [<ffffffff810f9d21>] __alloc_pages_slowpath+0x511/0x580
[  303.112786]  [<ffffffff810f9eee>] __alloc_pages_nodemask+0x15e/0x1a0
[  303.112792]  [<ffffffff8112cb12>] alloc_page_vma+0x72/0xf0
[  303.112797]  [<ffffffff810fe741>] ? lru_cache_add_lru+0x21/0x40
[  303.112803]  [<ffffffff81110580>] do_anonymous_page+0x100/0x260
[  303.112807]  [<ffffffff811150ff>] handle_mm_fault+0x31f/0x3c0
[  303.112813]  [<ffffffff810397a9>] ? default_spin_lock_flags+0x9/0x10
[  303.112819]  [<ffffffff8154380a>] do_page_fault+0x12a/0x3b0
[  303.112824]  [<ffffffff81541165>] page_fault+0x25/0x30
[  303.112827] Mem-Info:
[  303.112830] Node 0 DMA per-cpu:
[  303.112834] CPU    0: hi:    0, btch:   1 usd:   0
[  303.112836] CPU    1: hi:    0, btch:   1 usd:   0
[  303.112839] Node 0 DMA32 per-cpu:
[  303.112842] CPU    0: hi:  186, btch:  31 usd: 168
[  303.112845] CPU    1: hi:  186, btch:  31 usd: 114
[  303.112850] active_anon:374917 inactive_anon:82293 isolated_anon:0
[  303.112852]  active_file:6678 inactive_file:6756 isolated_file:33
[  303.112853]  unevictable:0 dirty:0 writeback:0 unstable:0
[  303.112854]  free:3380 slab_reclaimable:3969 slab_unreclaimable:4366
[  303.112856]  mapped:12857 shmem:44508 pagetables:5296 bounce:0
[  303.112858] Node 0 DMA free:7920kB min:40kB low:48kB high:60kB
active_anon:3880kB inactive_anon:4096kB active_file:0kB
inactive_file:0kB unevictable:0kB isolated(anon):0kB
isolated(file):0kB present:15348kB mlocked:0kB dirty:0kB writeback:0kB
mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:8kB
kernel_stack:0kB pagetables:16kB unstable:0kB bounce:0kB
writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[  303.112871] lowmem_reserve[]: 0 1971 1971 1971
[  303.112876] Node 0 DMA32 free:5600kB min:5660kB low:7072kB
high:8488kB active_anon:1495788kB inactive_anon:325076kB
active_file:26712kB inactive_file:27024kB unevictable:0kB
isolated(anon):0kB isolated(file):132kB present:2019172kB mlocked:0kB
dirty:0kB writeback:0kB mapped:51428kB shmem:178032kB
slab_reclaimable:15876kB slab_unreclaimable:17456kB
kernel_stack:2072kB pagetables:21168kB unstable:0kB bounce:0kB
writeback_tmp:0kB pages_scanned:63493 all_unreclaimable? no
[  303.112889] lowmem_reserve[]: 0 0 0 0
[  303.112894] Node 0 DMA: 4*4kB 2*8kB 1*16kB 2*32kB 2*64kB 2*128kB
1*256kB 2*512kB 2*1024kB 2*2048kB 0*4096kB = 7920kB
[  303.112909] Node 0 DMA32: 374*4kB 1*8kB 0*16kB 0*32kB 0*64kB
0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 1*4096kB = 5600kB
[  303.112922] 57976 total pagecache pages
[  303.112925] 0 pages in swap cache
[  303.112928] Swap cache stats: add 0, delete 0, find 0/0
[  303.112930] Free swap  = 0kB
[  303.112931] Total swap = 0kB
[  303.120149] 515887 pages RAM
[  303.120153] 9764 pages reserved
[  303.120155] 103221 pages shared
[  303.120158] 468651 pages non-shared
[  303.120162] Out of memory: kill process 3821 (gnome-session) score
380210 or a child
[  303.120168] Killed process 3889 (polkit-gnome-au)
[  303.460215] clock-applet invoked oom-killer: gfp_mask=0xd0,
order=0, oom_adj=0
[  303.460222] clock-applet cpuset=/ mems_allowed=0
[  303.460227] Pid: 4034, comm: clock-applet Not tainted
2.6.32-21-generic #32-Ubuntu
[  303.460230] Call Trace:
[  303.460243]  [<ffffffff810b37cd>] ? cpuset_print_task_mems_allowed+0x9d/0xb0
[  303.460250]  [<ffffffff810f64f4>] oom_kill_process+0xd4/0x2f0
[  303.460254]  [<ffffffff810f6ab0>] ? select_bad_process+0xd0/0x110
[  303.460259]  [<ffffffff810f6b48>] __out_of_memory+0x58/0xc0
[  303.460264]  [<ffffffff810f6cde>] out_of_memory+0x12e/0x1a0
[  303.460270]  [<ffffffff81540c9e>] ? _spin_lock+0xe/0x20
[  303.460275]  [<ffffffff810f9d21>] __alloc_pages_slowpath+0x511/0x580
[  303.460280]  [<ffffffff810f9eee>] __alloc_pages_nodemask+0x15e/0x1a0
[  303.460287]  [<ffffffff8112ca57>] alloc_pages_current+0x87/0xd0
[  303.460292]  [<ffffffff810f8e0e>] __get_free_pages+0xe/0x50
[  303.460298]  [<ffffffff81154994>] __pollwait+0xb4/0xf0
[  303.460303]  [<ffffffff814e09a5>] unix_poll+0x25/0xc0
[  303.460309]  [<ffffffff81449bea>] sock_poll+0x1a/0x20
[  303.460314]  [<ffffffff81153f95>] do_poll+0x115/0x2c0
[  303.460319]  [<ffffffff810fb3ad>] ? free_hot_page+0x2d/0x60
[  303.460324]  [<ffffffff81154b85>] do_sys_poll+0x155/0x210
[  303.460328]  [<ffffffff811548e0>] ? __pollwait+0x0/0xf0
[  303.460333]  [<ffffffff811549d0>] ? pollwake+0x0/0x60
[  303.460337]  [<ffffffff811549d0>] ? pollwake+0x0/0x60
[  303.460342]  [<ffffffff811549d0>] ? pollwake+0x0/0x60
[  303.460346]  [<ffffffff811549d0>] ? pollwake+0x0/0x60
[  303.460351]  [<ffffffff811549d0>] ? pollwake+0x0/0x60
[  303.460355]  [<ffffffff811549d0>] ? pollwake+0x0/0x60
[  303.460359]  [<ffffffff811549d0>] ? pollwake+0x0/0x60
[  303.460364]  [<ffffffff811549d0>] ? pollwake+0x0/0x60
[  303.460368]  [<ffffffff811549d0>] ? pollwake+0x0/0x60
[  303.460375]  [<ffffffff81019e89>] ? read_tsc+0x9/0x20
[  303.460381]  [<ffffffff8108f9c9>] ? ktime_get_ts+0xa9/0xe0
[  303.460386]  [<ffffffff81153e0d>] ? poll_select_set_timeout+0x8d/0xa0
[  303.460391]  [<ffffffff81154e3c>] sys_poll+0x7c/0x110
[  303.460397]  [<ffffffff810131b2>] system_call_fastpath+0x16/0x1b
[  303.460400] Mem-Info:
[  303.460403] Node 0 DMA per-cpu:
[  303.460407] CPU    0: hi:    0, btch:   1 usd:   0
[  303.460410] CPU    1: hi:    0, btch:   1 usd:   0
[  303.460412] Node 0 DMA32 per-cpu:
[  303.460416] CPU    0: hi:  186, btch:  31 usd: 177
[  303.460419] CPU    1: hi:  186, btch:  31 usd:  72
[  303.460425] active_anon:375232 inactive_anon:82145 isolated_anon:0
[  303.460426]  active_file:6651 inactive_file:6755 isolated_file:33
[  303.460427]  unevictable:0 dirty:0 writeback:0 unstable:0
[  303.460429]  free:3380 slab_reclaimable:3969 slab_unreclaimable:4366
[  303.460430]  mapped:12826 shmem:44508 pagetables:5203 bounce:0
[  303.460433] Node 0 DMA free:7920kB min:40kB low:48kB high:60kB
active_anon:3880kB inactive_anon:4096kB active_file:0kB
inactive_file:0kB unevictable:0kB isolated(anon):0kB
isolated(file):0kB present:15348kB mlocked:0kB dirty:0kB writeback:0kB
mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:8kB
kernel_stack:0kB pagetables:16kB unstable:0kB bounce:0kB
writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[  303.460445] lowmem_reserve[]: 0 1971 1971 1971
[  303.460451] Node 0 DMA32 free:5600kB min:5660kB low:7072kB
high:8488kB active_anon:1497048kB inactive_anon:324484kB
active_file:26604kB inactive_file:27020kB unevictable:0kB
isolated(anon):0kB isolated(file):132kB present:2019172kB mlocked:0kB
dirty:0kB writeback:0kB mapped:51304kB shmem:178032kB
slab_reclaimable:15876kB slab_unreclaimable:17456kB
kernel_stack:2072kB pagetables:20796kB unstable:0kB bounce:0kB
writeback_tmp:0kB pages_scanned:38786 all_unreclaimable? no
[  303.460464] lowmem_reserve[]: 0 0 0 0
[  303.460469] Node 0 DMA: 4*4kB 2*8kB 1*16kB 2*32kB 2*64kB 2*128kB
1*256kB 2*512kB 2*1024kB 2*2048kB 0*4096kB = 7920kB
[  303.460483] Node 0 DMA32: 378*4kB 1*8kB 0*16kB 0*32kB 0*64kB
0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 1*4096kB = 5616kB
[  303.460497] 57976 total pagecache pages
[  303.460500] 0 pages in swap cache
[  303.460502] Swap cache stats: add 0, delete 0, find 0/0
[  303.460505] Free swap  = 0kB
[  303.460506] Total swap = 0kB
[  303.467705] 515887 pages RAM
[  303.467709] 9764 pages reserved
[  303.467711] 101853 pages shared
[  303.467713] 468702 pages non-shared
[  303.467717] Out of memory: kill process 4210 (a.out) score 365712 or a child
[  303.467723] Killed process 4210 (a.out)
ubuntu@ubuntu:~/Desktop$




and here is the dmesg for the system:


[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 2.6.32-21-generic (buildd@yellow) (gcc
version 4.4.3 (Ubuntu 4.4.3-4ubuntu5) ) #32-Ubuntu SMP Fri Apr 16
08:09:38 UTC 2010 (Ubuntu 2.6.32-21.32-generic 2.6.32.11+drm33.2)
[    0.000000] Command line: BOOT_IMAGE=/casper/vmlinuz
file=/cdrom/preseed/ubuntu.seed boot=casper initrd=/casper/initrd.lz
quiet splash --
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000]   AMD AuthenticAMD
[    0.000000]   Centaur CentaurHauls
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
[    0.000000]  BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000e6000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000007df2f800 (usable)
[    0.000000]  BIOS-e820: 000000007df2f800 - 000000007df30000 (ACPI NVS)
[    0.000000]  BIOS-e820: 000000007df30000 - 000000007df40000 (ACPI data)
[    0.000000]  BIOS-e820: 000000007df40000 - 000000007dff0000 (ACPI NVS)
[    0.000000]  BIOS-e820: 000000007dff0000 - 000000007e000000 (reserved)
[    0.000000]  BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
[    0.000000]  BIOS-e820: 00000000fed13000 - 00000000fed1a000 (reserved)
[    0.000000]  BIOS-e820: 00000000fed1c000 - 00000000feda0000 (reserved)
[    0.000000] DMI 2.3 present.
[    0.000000] last_pfn = 0x7df2f max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-EFFFF uncachable
[    0.000000]   F0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000000000 mask F80000000 write-back
[    0.000000]   1 base 07E000000 mask FFE000000 uncachable
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
[    0.000000] e820 update range: 0000000000001000 - 0000000000006000
(usable) ==> (reserved)
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] modified physical RAM map:
[    0.000000]  modified: 0000000000000000 - 0000000000001000 (usable)
[    0.000000]  modified: 0000000000001000 - 0000000000006000 (reserved)
[    0.000000]  modified: 0000000000006000 - 000000000009fc00 (usable)
[    0.000000]  modified: 000000000009fc00 - 00000000000a0000 (reserved)
[    0.000000]  modified: 00000000000e6000 - 0000000000100000 (reserved)
[    0.000000]  modified: 0000000000100000 - 000000007df2f800 (usable)
[    0.000000]  modified: 000000007df2f800 - 000000007df30000 (ACPI NVS)
[    0.000000]  modified: 000000007df30000 - 000000007df40000 (ACPI data)
[    0.000000]  modified: 000000007df40000 - 000000007dff0000 (ACPI NVS)
[    0.000000]  modified: 000000007dff0000 - 000000007e000000 (reserved)
[    0.000000]  modified: 00000000e0000000 - 00000000f0000000 (reserved)
[    0.000000]  modified: 00000000fed13000 - 00000000fed1a000 (reserved)
[    0.000000]  modified: 00000000fed1c000 - 00000000feda0000 (reserved)
[    0.000000] initial memory mapped : 0 - 20000000
[    0.000000] init_memory_mapping: 0000000000000000-000000007df2f000
[    0.000000] NX (Execute Disable) protection: active
[    0.000000]  0000000000 - 007de00000 page 2M
[    0.000000]  007de00000 - 007df2f000 page 4k
[    0.000000] kernel direct mapping tables up to 7df2f000 @ 8000-c000
[    0.000000] RAMDISK: 7d59e000 - 7deffcaf
[    0.000000] ACPI: RSDP 00000000000f4eb0 00014 (v00 ACPIAM)
[    0.000000] ACPI: RSDT 000000007df30000 0003C (v01 INTEL  D915GAG
20060222 MSFT 00000097)
[    0.000000] ACPI: FACP 000000007df30200 00081 (v02 INTEL  D915GAG
20060222 MSFT 00000097)
[    0.000000] ACPI: DSDT 000000007df30440 05C05 (v01 INTEL  D915GAG
00000001 INTL 02002026)
[    0.000000] ACPI: FACS 000000007df40000 00040
[    0.000000] ACPI: APIC 000000007df30390 00068 (v01 INTEL  D915GAG
20060222 MSFT 00000097)
[    0.000000] ACPI: MCFG 000000007df30400 0003C (v01 INTEL  D915GAG
20060222 MSFT 00000097)
[    0.000000] ACPI: ASF! 000000007df36050 00099 (v16 LEGEND I865PASF
00000001 INTL 02002026)
[    0.000000] ACPI: TCPA 000000007df360f0 00032 (v01 INTEL  TBLOEMID
00000001 MSFT 00000097)
[    0.000000] ACPI: WDDT 000000007df36122 00040 (v01 INTEL  OEMWDDT
00000001 INTL 02002026)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at 0000000000000000-000000007df2f000
[    0.000000] Bootmem setup node 0 0000000000000000-000000007df2f000
[    0.000000]   NODE_DATA [000000000000a000 - 000000000000efff]
[    0.000000]   bootmap [000000000000f000 -  000000000001ebe7] pages 10
[    0.000000] (7 early reservations) ==> bootmem [0000000000 - 007df2f000]
[    0.000000]   #0 [0000000000 - 0000001000]   BIOS data page ==>
[0000000000 - 0000001000]
[    0.000000]   #1 [0000006000 - 0000008000]       TRAMPOLINE ==>
[0000006000 - 0000008000]
[    0.000000]   #2 [0001000000 - 0001a29e64]    TEXT DATA BSS ==>
[0001000000 - 0001a29e64]
[    0.000000]   #3 [007d59e000 - 007deffcaf]          RAMDISK ==>
[007d59e000 - 007deffcaf]
[    0.000000]   #4 [000009fc00 - 0000100000]    BIOS reserved ==>
[000009fc00 - 0000100000]
[    0.000000]   #5 [0001a2a000 - 0001a2a1b4]              BRK ==>
[0001a2a000 - 0001a2a1b4]
[    0.000000]   #6 [0000008000 - 000000a000]          PGTABLE ==>
[0000008000 - 000000a000]
[    0.000000] found SMP MP-table at [ffff8800000ff780] ff780
[    0.000000]  [ffffea0000000000-ffffea0001bfffff] PMD ->
[ffff880002000000-ffff880003bfffff] on node 0
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000000 -> 0x00001000
[    0.000000]   DMA32    0x00001000 -> 0x00100000
[    0.000000]   Normal   0x00100000 -> 0x00100000
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[3] active PFN ranges
[    0.000000]     0: 0x00000000 -> 0x00000001
[    0.000000]     0: 0x00000006 -> 0x0000009f
[    0.000000]     0: 0x00000100 -> 0x0007df2f
[    0.000000] On node 0 totalpages: 515785
[    0.000000]   DMA zone: 56 pages used for memmap
[    0.000000]   DMA zone: 101 pages reserved
[    0.000000]   DMA zone: 3837 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 6998 pages used for memmap
[    0.000000]   DMA32 zone: 504793 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] dfl dfl lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] SMP: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] nr_irqs_gsi: 24
[    0.000000] PM: Registered nosave memory: 0000000000001000 - 0000000000006000
[    0.000000] PM: Registered nosave memory: 000000000009f000 - 00000000000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 00000000000e6000
[    0.000000] PM: Registered nosave memory: 00000000000e6000 - 0000000000100000
[    0.000000] Allocating PCI resources starting at 7e000000 (gap:
7e000000:62000000)
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] NR_CPUS:64 nr_cpumask_bits:64 nr_cpu_ids:2 nr_node_ids:1
[    0.000000] PERCPU: Embedded 30 pages/cpu @ffff880001c00000 s91544
r8192 d23144 u1048576
[    0.000000] pcpu-alloc: s91544 r8192 d23144 u1048576 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 1
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.
Total pages: 508630
[    0.000000] Policy zone: DMA32
[    0.000000] Kernel command line: BOOT_IMAGE=/casper/vmlinuz
file=/cdrom/preseed/ubuntu.seed boot=casper initrd=/casper/initrd.lz
quiet splash --
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Initializing CPU#0
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Calgary: detecting Calgary via BIOS EBDA area
[    0.000000] Calgary: Unable to locate Rio Grande table in EBDA - bailing!
[    0.000000] Memory: 2014032k/2063548k available (5409k kernel code,
408k absent, 49108k reserved, 2976k data, 876k init)
[    0.000000] SLUB: Genslabs=14, HWalign=64, Order=0-3, MinObjects=0,
CPUs=2, Nodes=1
[    0.000000] Hierarchical RCU implementation.
[    0.000000] NR_IRQS:4352 nr_irqs:424
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] allocated 20971520 bytes of page_cgroup
[    0.000000] please try 'cgroup_disable=memory' option if you don't
want memory cgroups
[    0.000000] Fast TSC calibration using PIT
[    0.000000] Detected 3000.196 MHz processor.
[    0.010010] Calibrating delay loop (skipped), value calculated
using timer frequency.. 6000.39 BogoMIPS (lpj=30001960)
[    0.010047] Security Framework initialized
[    0.010074] AppArmor: AppArmor initialized
[    0.010421] Dentry cache hash table entries: 262144 (order: 9, 2097152 bytes)
[    0.011776] Inode-cache hash table entries: 131072 (order: 8, 1048576 bytes)
[    0.012432] Mount-cache hash table entries: 256
[    0.012648] Initializing cgroup subsys ns
[    0.012655] Initializing cgroup subsys cpuacct
[    0.012660] Initializing cgroup subsys memory
[    0.012672] Initializing cgroup subsys devices
[    0.012676] Initializing cgroup subsys freezer
[    0.012679] Initializing cgroup subsys net_cls
[    0.012713] CPU: Trace cache: 12K uops, L1 D cache: 16K
[    0.012718] CPU: L2 cache: 1024K
[    0.012722] CPU 0/0x0 -> Node 0
[    0.012725] CPU: Physical Processor ID: 0
[    0.012727] CPU: Processor Core ID: 0
[    0.012731] mce: CPU supports 4 MCE banks
[    0.012746] CPU0: Thermal monitoring enabled (TM1)
[    0.012753] using mwait in idle threads.
[    0.012756] Performance Events: no PMU driver, software events only.
[    0.021475] ACPI: Core revision 20090903
[    0.033331] ftrace: converting mcount calls to 0f 1f 44 00 00
[    0.033338] ftrace: allocating 22518 entries in 89 pages
[    0.040090] Setting APIC routing to flat
[    0.040411] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.148236] CPU0: Intel(R) Pentium(R) 4 CPU 3.00GHz stepping 01
[    0.150000] Booting processor 1 APIC 0x1 ip 0x6000
[    0.020000] Initializing CPU#1
[    0.020000] CPU: Trace cache: 12K uops, L1 D cache: 16K
[    0.020000] CPU: L2 cache: 1024K
[    0.020000] CPU 1/0x1 -> Node 0
[    0.020000] CPU: Physical Processor ID: 0
[    0.020000] CPU: Processor Core ID: 0
[    0.020000] CPU1: Thermal monitoring enabled (TM1)
[    0.300148] CPU1: Intel(R) Pentium(R) 4 CPU 3.00GHz stepping 01
[    0.300160] checking TSC synchronization [CPU#0 -> CPU#1]: passed.
[    0.310028] Brought up 2 CPUs
[    0.310033] Total of 2 processors activated (12000.71 BogoMIPS).
[    0.310374] CPU0 attaching sched-domain:
[    0.310380]  domain 0: span 0-1 level SIBLING
[    0.310384]   groups: 0 (cpu_power = 589) 1 (cpu_power = 589)
[    0.310392]   domain 1: span 0-1 level MC
[    0.310395]    groups: 0-1 (cpu_power = 1178)
[    0.310405] CPU1 attaching sched-domain:
[    0.310408]  domain 0: span 0-1 level SIBLING
[    0.310411]   groups: 1 (cpu_power = 589) 0 (cpu_power = 589)
[    0.310418]   domain 1: span 0-1 level MC
[    0.310420]    groups: 0-1 (cpu_power = 1178)
[    0.310580] devtmpfs: initialized
[    0.310580] regulator: core version 0.5
[    0.310580] Time: 10:18:35  Date: 07/27/10
[    0.310600] NET: Registered protocol family 16
[    0.310641] Trying to unpack rootfs image as initramfs...
[    0.310875] ACPI: bus type pci registered
[    0.310994] PCI: MCFG configuration 0: base e0000000 segment 0 buses 0 - 255
[    0.311000] PCI: MCFG area at e0000000 reserved in E820
[    0.321206] PCI: Using MMCONFIG at e0000000 - efffffff
[    0.321213] PCI: Using configuration type 1 for base access
[    0.323076] bio: create slab <bio-0> at 0
[    0.324571] ACPI: EC: Look up EC in DSDT
[    0.329130] ACPI: Executed 4 blocks of module-level executable AML code
[    0.339004] ACPI: Interpreter enabled
[    0.339012] ACPI: (supports S0 S1 S3 S4 S5)
[    0.339061] ACPI: Using IOAPIC for interrupt routing
[    0.352264] ACPI: Power Resource [URP1] (off)
[    0.352331] ACPI: Power Resource [FDDP] (off)
[    0.352400] ACPI: Power Resource [LPTP] (off)
[    0.352466] ACPI: Power Resource [URP2] (off)
[    0.352837] ACPI: No dock devices found.
[    0.355090] ACPI Warning for \_SB_.PCI0._OSC: Parameter count
mismatch - ASL declared 5, ACPI requires 4 (20090903/nspredef-336)
[    0.355106] ACPI: PCI Root Bridge [PCI0] (0000:00)
[    0.355295] pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
[    0.355302] pci 0000:00:01.0: PME# disabled
[    0.355338] pci 0000:00:02.0: reg 10 32bit mmio: [0xff480000-0xff4fffff]
[    0.355347] pci 0000:00:02.0: reg 14 io port: [0xec00-0xec07]
[    0.355355] pci 0000:00:02.0: reg 18 32bit mmio pref: [0xd0000000-0xdfffffff]
[    0.355363] pci 0000:00:02.0: reg 1c 32bit mmio: [0xff440000-0xff47ffff]
[    0.355466] pci 0000:00:1b.0: reg 10 64bit mmio: [0xff43c000-0xff43ffff]
[    0.355521] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
[    0.355527] pci 0000:00:1b.0: PME# disabled
[    0.355612] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    0.355619] pci 0000:00:1c.0: PME# disabled
[    0.355704] pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
[    0.355711] pci 0000:00:1c.1: PME# disabled
[    0.355796] pci 0000:00:1c.2: PME# supported from D0 D3hot D3cold
[    0.355803] pci 0000:00:1c.2: PME# disabled
[    0.355887] pci 0000:00:1c.3: PME# supported from D0 D3hot D3cold
[    0.355894] pci 0000:00:1c.3: PME# disabled
[    0.355958] pci 0000:00:1d.0: reg 20 io port: [0xc800-0xc81f]
[    0.356026] pci 0000:00:1d.1: reg 20 io port: [0xcc00-0xcc1f]
[    0.356090] pci 0000:00:1d.2: reg 20 io port: [0xd000-0xd01f]
[    0.356154] pci 0000:00:1d.3: reg 20 io port: [0xd400-0xd41f]
[    0.356225] pci 0000:00:1d.7: reg 10 32bit mmio: [0xff43bc00-0xff43bfff]
[    0.356289] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
[    0.356296] pci 0000:00:1d.7: PME# disabled
[    0.356443] pci 0000:00:1f.0: Force enabled HPET at 0xfed00000
[    0.356455] pci 0000:00:1f.0: quirk: region 0400-047f claimed by
ICH6 ACPI/GPIO/TCO
[    0.356461] pci 0000:00:1f.0: quirk: region 0500-053f claimed by ICH6 GPIO
[    0.356468] pci 0000:00:1f.0: LPC Generic IO decode 1 PIO at 0680-06ff
[    0.356474] pci 0000:00:1f.0: LPC Generic IO decode 2 PIO at 4700-470f
[    0.356507] pci 0000:00:1f.1: reg 10 io port: [0x00-0x07]
[    0.356517] pci 0000:00:1f.1: reg 14 io port: [0x00-0x03]
[    0.356526] pci 0000:00:1f.1: reg 18 io port: [0x00-0x07]
[    0.356535] pci 0000:00:1f.1: reg 1c io port: [0x00-0x03]
[    0.356545] pci 0000:00:1f.1: reg 20 io port: [0xffa0-0xffaf]
[    0.356600] pci 0000:00:1f.2: reg 10 io port: [0xe800-0xe807]
[    0.356610] pci 0000:00:1f.2: reg 14 io port: [0xe400-0xe403]
[    0.356618] pci 0000:00:1f.2: reg 18 io port: [0xe000-0xe007]
[    0.356627] pci 0000:00:1f.2: reg 1c io port: [0xdc00-0xdc03]
[    0.356636] pci 0000:00:1f.2: reg 20 io port: [0xd800-0xd80f]
[    0.356668] pci 0000:00:1f.2: PME# supported from D3hot
[    0.356674] pci 0000:00:1f.2: PME# disabled
[    0.356736] pci 0000:00:1f.3: reg 20 io port: [0xc400-0xc41f]
[    0.356828] pci 0000:00:01.0: bridge 32bit mmio: [0xffa00000-0xffafffff]
[    0.356835] pci 0000:00:01.0: bridge 32bit mmio pref: [0xcff00000-0xcfffffff]
[    0.356898] pci 0000:00:1c.0: bridge 32bit mmio: [0xff600000-0xff6fffff]
[    0.356908] pci 0000:00:1c.0: bridge 64bit mmio pref: [0xcfb00000-0xcfbfffff]
[    0.356970] pci 0000:00:1c.1: bridge 32bit mmio: [0xff700000-0xff7fffff]
[    0.356980] pci 0000:00:1c.1: bridge 64bit mmio pref: [0xcfc00000-0xcfcfffff]
[    0.357042] pci 0000:00:1c.2: bridge 32bit mmio: [0xff800000-0xff8fffff]
[    0.357052] pci 0000:00:1c.2: bridge 64bit mmio pref: [0xcfd00000-0xcfdfffff]
[    0.357112] pci 0000:00:1c.3: bridge 32bit mmio: [0xff900000-0xff9fffff]
[    0.357123] pci 0000:00:1c.3: bridge 64bit mmio pref: [0xcfe00000-0xcfefffff]
[    0.357158] pci 0000:06:00.0: reg 10 io port: [0xbc00-0xbc3f]
[    0.357196] pci 0000:06:00.0: reg 30 32bit mmio pref: [0xff500000-0xff50ffff]
[    0.357248] pci 0000:06:01.0: reg 10 32bit mmio: [0xff511000-0xff5110ff]
[    0.357259] pci 0000:06:01.0: reg 14 io port: [0xb800-0xb807]
[    0.357269] pci 0000:06:01.0: reg 18 io port: [0xb400-0xb4ff]
[    0.357318] pci 0000:06:01.0: supports D2
[    0.357323] pci 0000:06:01.0: PME# supported from D2 D3hot
[    0.357330] pci 0000:06:01.0: PME# disabled
[    0.357386] pci 0000:06:08.0: reg 10 32bit mmio: [0xff510000-0xff510fff]
[    0.357396] pci 0000:06:08.0: reg 14 io port: [0xb000-0xb03f]
[    0.357448] pci 0000:06:08.0: supports D1 D2
[    0.357452] pci 0000:06:08.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.357459] pci 0000:06:08.0: PME# disabled
[    0.357509] pci 0000:00:1e.0: transparent bridge
[    0.357516] pci 0000:00:1e.0: bridge io port: [0xb000-0xbfff]
[    0.357522] pci 0000:00:1e.0: bridge 32bit mmio: [0xff500000-0xff5fffff]
[    0.357532] pci 0000:00:1e.0: bridge 64bit mmio pref: [0xcfa00000-0xcfafffff]
[    0.357569] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.357767] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEGP._PRT]
[    0.357871] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P2._PRT]
[    0.358149] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX1._PRT]
[    0.358253] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX2._PRT]
[    0.358356] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX3._PRT]
[    0.358459] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX4._PRT]
[    0.360173] ACPI Warning for \_SB_.PCI0._OSC: Parameter count
mismatch - ASL declared 5, ACPI requires 4 (20090903/nspredef-336)
[    0.368564] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 9 10
*11 12 14 15)
[    0.368848] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 9 10 11
12 14 15) *0, disabled.
[    0.369126] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 *5 6 7 9 10
11 12 14 15)
[    0.369402] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 9 *10
11 12 14 15)
[    0.369677] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 9 *10
11 12 14 15)
[    0.369954] ACPI: PCI Interrupt Link [LNKF] (IRQs *3 4 5 6 7 9 10
11 12 14 15)
[    0.370254] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 *9 10
11 12 14 15)
[    0.370532] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 *9 10
11 12 14 15)
[    0.370792] vgaarb: device added:
PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    0.370822] vgaarb: loaded
[    0.371032] SCSI subsystem initialized
[    0.371163] libata version 3.00 loaded.
[    0.371307] usbcore: registered new interface driver usbfs
[    0.371332] usbcore: registered new interface driver hub
[    0.371381] usbcore: registered new device driver usb
[    0.371627] ACPI: WMI: Mapper loaded
[    0.371630] PCI: Using ACPI for IRQ routing
[    0.371914] NetLabel: Initializing
[    0.371918] NetLabel:  domain hash size = 128
[    0.371922] NetLabel:  protocols = UNLABELED CIPSOv4
[    0.371947] NetLabel:  unlabeled traffic allowed by default
[    0.372095] hpet clockevent registered
[    0.372105] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
[    0.372112] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.372123] hpet0: 3 comparators, 64-bit 14.318180 MHz counter
[    2.962643] Switching to clocksource tsc
[    2.963674] AppArmor: AppArmor Filesystem Enabled
[    2.963722] pnp: PnP ACPI init
[    2.963772] ACPI: bus type pnp registered
[    2.971992] pnp: PnP ACPI: found 13 devices
[    2.972000] ACPI: ACPI bus type pnp unregistered
[    2.972046] system 00:08: ioport range 0x4d0-0x4d1 has been reserved
[    2.972053] system 00:08: ioport range 0x400-0x47f has been reserved
[    2.972059] system 00:08: ioport range 0x500-0x53f has been reserved
[    2.972080] system 00:0a: iomem range 0xffc00000-0xfff7ffff has been reserved
[    2.972093] system 00:0b: ioport range 0x400-0x47f has been reserved
[    2.972099] system 00:0b: ioport range 0x680-0x6ff has been reserved
[    2.972105] system 00:0b: ioport range 0x500-0x53f has been reserved
[    2.972111] system 00:0b: iomem range 0xeec00000-0xeec03fff has been reserved
[    2.972117] system 00:0b: iomem range 0xfec00000-0xfec00fff could
not be reserved
[    2.972123] system 00:0b: iomem range 0xfee00000-0xfee00fff has been reserved
[    2.972128] system 00:0b: iomem range 0xe0000000-0xefffffff could
not be reserved
[    2.972134] system 00:0b: iomem range 0xfed13000-0xfed13fff has been reserved
[    2.972140] system 00:0b: iomem range 0xfed14000-0xfed17fff has been reserved
[    2.972146] system 00:0b: iomem range 0xfed18000-0xfed18fff has been reserved
[    2.972151] system 00:0b: iomem range 0xfed19000-0xfed19fff has been reserved
[    2.972157] system 00:0b: iomem range 0xfed1c000-0xfed1ffff has been reserved
[    2.972163] system 00:0b: iomem range 0xfed20000-0xfed9ffff has been reserved
[    2.972176] system 00:0c: iomem range 0x0-0x9ffff could not be reserved
[    2.972181] system 00:0c: iomem range 0xc0000-0xdffff has been reserved
[    2.972187] system 00:0c: iomem range 0xe0000-0xfffff could not be reserved
[    2.972193] system 00:0c: iomem range 0x100000-0x7dffffff could not
be reserved
[    2.977269] pci 0000:06:00.0: BAR 6: address space collision on of
device [0xff500000-0xff50ffff]
[    2.977364] pci 0000:00:01.0: PCI bridge, secondary bus 0000:01
[    2.977368] pci 0000:00:01.0:   IO window: disabled
[    2.977376] pci 0000:00:01.0:   MEM window: 0xffa00000-0xffafffff
[    2.977382] pci 0000:00:01.0:   PREFETCH window: 0xcff00000-0xcfffffff
[    2.977391] pci 0000:00:1c.0: PCI bridge, secondary bus 0000:05
[    2.977397] pci 0000:00:1c.0:   IO window: 0x1000-0x1fff
[    2.977406] pci 0000:00:1c.0:   MEM window: 0xff600000-0xff6fffff
[    2.977412] pci 0000:00:1c.0:   PREFETCH window:
0x000000cfb00000-0x000000cfbfffff
[    2.977423] pci 0000:00:1c.1: PCI bridge, secondary bus 0000:04
[    2.977428] pci 0000:00:1c.1:   IO window: 0x2000-0x2fff
[    2.977436] pci 0000:00:1c.1:   MEM window: 0xff700000-0xff7fffff
[    2.977444] pci 0000:00:1c.1:   PREFETCH window:
0x000000cfc00000-0x000000cfcfffff
[    2.977454] pci 0000:00:1c.2: PCI bridge, secondary bus 0000:03
[    2.977459] pci 0000:00:1c.2:   IO window: 0x3000-0x3fff
[    2.977467] pci 0000:00:1c.2:   MEM window: 0xff800000-0xff8fffff
[    2.977474] pci 0000:00:1c.2:   PREFETCH window:
0x000000cfd00000-0x000000cfdfffff
[    2.977484] pci 0000:00:1c.3: PCI bridge, secondary bus 0000:02
[    2.977490] pci 0000:00:1c.3:   IO window: 0x4000-0x4fff
[    2.977499] pci 0000:00:1c.3:   MEM window: 0xff900000-0xff9fffff
[    2.977506] pci 0000:00:1c.3:   PREFETCH window:
0x000000cfe00000-0x000000cfefffff
[    2.977524] pci 0000:00:1e.0: PCI bridge, secondary bus 0000:06
[    2.977531] pci 0000:00:1e.0:   IO window: 0xb000-0xbfff
[    2.977538] pci 0000:00:1e.0:   MEM window: 0xff500000-0xff5fffff
[    2.977546] pci 0000:00:1e.0:   PREFETCH window:
0x000000cfa00000-0x000000cfafffff
[    2.977574]   alloc irq_desc for 16 on node -1
[    2.977580]   alloc kstat_irqs on node -1
[    2.977594] pci 0000:00:01.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    2.977602] pci 0000:00:01.0: setting latency timer to 64
[    2.977618] pci 0000:00:1c.0: enabling device (0106 -> 0107)
[    2.977625]   alloc irq_desc for 17 on node -1
[    2.977629]   alloc kstat_irqs on node -1
[    2.977637] pci 0000:00:1c.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[    2.977645] pci 0000:00:1c.0: setting latency timer to 64
[    2.977659] pci 0000:00:1c.1: enabling device (0106 -> 0107)
[    2.977667] pci 0000:00:1c.1: PCI INT B -> GSI 16 (level, low) -> IRQ 16
[    2.977674] pci 0000:00:1c.1: setting latency timer to 64
[    2.977687] pci 0000:00:1c.2: enabling device (0106 -> 0107)
[    2.977694]   alloc irq_desc for 18 on node -1
[    2.977697]   alloc kstat_irqs on node -1
[    2.977704] pci 0000:00:1c.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[    2.977712] pci 0000:00:1c.2: setting latency timer to 64
[    2.977725] pci 0000:00:1c.3: enabling device (0106 -> 0107)
[    2.977731]   alloc irq_desc for 19 on node -1
[    2.977735]   alloc kstat_irqs on node -1
[    2.977741] pci 0000:00:1c.3: PCI INT D -> GSI 19 (level, low) -> IRQ 19
[    2.977748] pci 0000:00:1c.3: setting latency timer to 64
[    2.977758] pci 0000:00:1e.0: setting latency timer to 64
[    2.977766] pci_bus 0000:00: resource 0 io:  [0x00-0xffff]
[    2.977771] pci_bus 0000:00: resource 1 mem: [0x000000-0xffffffffffffffff]
[    2.977775] pci_bus 0000:01: resource 1 mem: [0xffa00000-0xffafffff]
[    2.977780] pci_bus 0000:01: resource 2 pref mem [0xcff00000-0xcfffffff]
[    2.977784] pci_bus 0000:05: resource 0 io:  [0x1000-0x1fff]
[    2.977789] pci_bus 0000:05: resource 1 mem: [0xff600000-0xff6fffff]
[    2.977793] pci_bus 0000:05: resource 2 pref mem [0xcfb00000-0xcfbfffff]
[    2.977798] pci_bus 0000:04: resource 0 io:  [0x2000-0x2fff]
[    2.977802] pci_bus 0000:04: resource 1 mem: [0xff700000-0xff7fffff]
[    2.977806] pci_bus 0000:04: resource 2 pref mem [0xcfc00000-0xcfcfffff]
[    2.977811] pci_bus 0000:03: resource 0 io:  [0x3000-0x3fff]
[    2.977815] pci_bus 0000:03: resource 1 mem: [0xff800000-0xff8fffff]
[    2.977819] pci_bus 0000:03: resource 2 pref mem [0xcfd00000-0xcfdfffff]
[    2.977824] pci_bus 0000:02: resource 0 io:  [0x4000-0x4fff]
[    2.977828] pci_bus 0000:02: resource 1 mem: [0xff900000-0xff9fffff]
[    2.977832] pci_bus 0000:02: resource 2 pref mem [0xcfe00000-0xcfefffff]
[    2.977839] pci_bus 0000:06: resource 0 io:  [0xb000-0xbfff]
[    2.977843] pci_bus 0000:06: resource 1 mem: [0xff500000-0xff5fffff]
[    2.977847] pci_bus 0000:06: resource 2 pref mem [0xcfa00000-0xcfafffff]
[    2.977851] pci_bus 0000:06: resource 3 io:  [0x00-0xffff]
[    2.977855] pci_bus 0000:06: resource 4 mem: [0x000000-0xffffffffffffffff]
[    2.977937] NET: Registered protocol family 2
[    2.978247] IP route cache hash table entries: 65536 (order: 7, 524288 bytes)
[    2.980101] TCP established hash table entries: 262144 (order: 10,
4194304 bytes)
[    2.983649] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    2.984430] TCP: Hash tables configured (established 262144 bind 65536)
[    2.984439] TCP reno registered
[    2.984674] NET: Registered protocol family 1
[    2.984726] pci 0000:00:02.0: Boot video device
[    2.984912] pci 0000:06:08.0: Firmware left e100 interrupts
enabled; disabling
[    2.985413] Scanning for low memory corruption every 60 seconds
[    2.985738] audit: initializing netlink socket (disabled)
[    2.985764] type=2000 audit(1280225917.980:1): initialized
[    2.997279] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    3.000425] VFS: Disk quotas dquot_6.5.2
[    3.000576] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    3.002018] fuse init (API version 7.13)
[    3.002225] msgmni has been set to 3933
[    3.002836] alg: No test for stdrng (krng)
[    3.003017] Block layer SCSI generic (bsg) driver version 0.4
loaded (major 253)
[    3.003024] io scheduler noop registered
[    3.003028] io scheduler anticipatory registered
[    3.003032] io scheduler deadline registered
[    3.003111] io scheduler cfq registered (default)
[    3.003383]   alloc irq_desc for 24 on node -1
[    3.003388]   alloc kstat_irqs on node -1
[    3.003405] pcieport 0000:00:01.0: irq 24 for MSI/MSI-X
[    3.003416] pcieport 0000:00:01.0: setting latency timer to 64
[    3.003579]   alloc irq_desc for 25 on node -1
[    3.003583]   alloc kstat_irqs on node -1
[    3.003595] pcieport 0000:00:1c.0: irq 25 for MSI/MSI-X
[    3.003607] pcieport 0000:00:1c.0: setting latency timer to 64
[    3.003784]   alloc irq_desc for 26 on node -1
[    3.003788]   alloc kstat_irqs on node -1
[    3.003800] pcieport 0000:00:1c.1: irq 26 for MSI/MSI-X
[    3.003812] pcieport 0000:00:1c.1: setting latency timer to 64
[    3.004000]   alloc irq_desc for 27 on node -1
[    3.004004]   alloc kstat_irqs on node -1
[    3.004015] pcieport 0000:00:1c.2: irq 27 for MSI/MSI-X
[    3.004027] pcieport 0000:00:1c.2: setting latency timer to 64
[    3.004210]   alloc irq_desc for 28 on node -1
[    3.004215]   alloc kstat_irqs on node -1
[    3.004228] pcieport 0000:00:1c.3: irq 28 for MSI/MSI-X
[    3.004240] pcieport 0000:00:1c.3: setting latency timer to 64
[    3.004409] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    3.004445] Firmware did not grant requested _OSC control
[    3.004482] Firmware did not grant requested _OSC control
[    3.004512] Firmware did not grant requested _OSC control
[    3.004541] Firmware did not grant requested _OSC control
[    3.004602] Firmware did not grant requested _OSC control
[    3.004629] Firmware did not grant requested _OSC control
[    3.004655] Firmware did not grant requested _OSC control
[    3.004681] Firmware did not grant requested _OSC control
[    3.004710] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    3.004934] input: Power Button as
/devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input0
[    3.004953] ACPI: Power Button [PWRB]
[    3.005046] input: Power Button as
/devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
[    3.005052] ACPI: Power Button [PWRF]
[    3.005777] processor LNXCPU:00: registered as cooling_device0
[    3.005882] processor LNXCPU:01: registered as cooling_device1
[    3.013381] Linux agpgart interface v0.103
[    3.013471] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    3.013641] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    3.014204] 00:06: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    3.016522] brd: module loaded
[    3.017565] loop: module loaded
[    3.017784] input: Macintosh mouse button emulation as
/devices/virtual/input/input2
[    3.018001] ata_piix 0000:00:1f.1: version 2.13
[    3.018031] ata_piix 0000:00:1f.1: PCI INT A -> GSI 18 (level, low) -> IRQ 18
[    3.018110] ata_piix 0000:00:1f.1: setting latency timer to 64
[    3.018307] scsi0 : ata_piix
[    3.018517] scsi1 : ata_piix
[    3.020727] ata1: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0xffa0 irq 14
[    3.020737] ata2: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0xffa8 irq 15
[    3.020887] ata_piix 0000:00:1f.2: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[    3.020898] ata_piix 0000:00:1f.2: MAP [ P0 P2 P1 P3 ]
[    3.020989] ata_piix 0000:00:1f.2: setting latency timer to 64
[    3.021109] scsi2 : ata_piix
[    3.021544] scsi3 : ata_piix
[    3.024468] ata3: SATA max UDMA/133 cmd 0xe800 ctl 0xe400 bmdma 0xd800 irq 19
[    3.024476] ata4: SATA max UDMA/133 cmd 0xe000 ctl 0xdc00 bmdma 0xd808 irq 19
[    3.025398] Fixed MDIO Bus: probed
[    3.025482] PPP generic driver version 2.4.2
[    3.025599] tun: Universal TUN/TAP device driver, 1.6
[    3.025605] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[    3.025821] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    3.025882]   alloc irq_desc for 23 on node -1
[    3.025886]   alloc kstat_irqs on node -1
[    3.025898] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[    3.025936] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[    3.025943] ehci_hcd 0000:00:1d.7: EHCI Host Controller
[    3.026018] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned
bus number 1
[    3.026065] ehci_hcd 0000:00:1d.7: debug port 1
[    3.029957] ehci_hcd 0000:00:1d.7: cache line size of 128 is not supported
[    3.030007] ehci_hcd 0000:00:1d.7: irq 23, io mem 0xff43bc00
[    3.052534] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
[    3.052755] usb usb1: configuration #1 chosen from 1 choice
[    3.052809] hub 1-0:1.0: USB hub found
[    3.052822] hub 1-0:1.0: 8 ports detected
[    3.052950] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    3.052984] uhci_hcd: USB Universal Host Controller Interface driver
[    3.053045] uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[    3.053058] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[    3.053064] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[    3.053138] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned
bus number 2
[    3.053172] uhci_hcd 0000:00:1d.0: irq 23, io base 0x0000c800
[    3.053334] usb usb2: configuration #1 chosen from 1 choice
[    3.053384] hub 2-0:1.0: USB hub found
[    3.053395] hub 2-0:1.0: 2 ports detected
[    3.053479] uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[    3.053489] uhci_hcd 0000:00:1d.1: setting latency timer to 64
[    3.053494] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[    3.053556] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned
bus number 3
[    3.053587] uhci_hcd 0000:00:1d.1: irq 19, io base 0x0000cc00
[    3.053745] usb usb3: configuration #1 chosen from 1 choice
[    3.053793] hub 3-0:1.0: USB hub found
[    3.053804] hub 3-0:1.0: 2 ports detected
[    3.053881] uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[    3.053895] uhci_hcd 0000:00:1d.2: setting latency timer to 64
[    3.053900] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[    3.053961] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned
bus number 4
[    3.054004] uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000d000
[    3.054157] usb usb4: configuration #1 chosen from 1 choice
[    3.054209] hub 4-0:1.0: USB hub found
[    3.054221] hub 4-0:1.0: 2 ports detected
[    3.054297] uhci_hcd 0000:00:1d.3: PCI INT D -> GSI 16 (level, low) -> IRQ 16
[    3.054306] uhci_hcd 0000:00:1d.3: setting latency timer to 64
[    3.054312] uhci_hcd 0000:00:1d.3: UHCI Host Controller
[    3.054369] uhci_hcd 0000:00:1d.3: new USB bus registered, assigned
bus number 5
[    3.054409] uhci_hcd 0000:00:1d.3: irq 16, io base 0x0000d400
[    3.054563] usb usb5: configuration #1 chosen from 1 choice
[    3.054614] hub 5-0:1.0: USB hub found
[    3.054625] hub 5-0:1.0: 2 ports detected
[    3.054790] PNP: PS/2 Controller [PNP0303:PS2K] at 0x60,0x64 irq 1
[    3.054795] PNP: PS/2 appears to have AUX port disabled, if this is
incorrect please boot with i8042.nopnp
[    3.055521] serio: i8042 KBD port at 0x60,0x64 irq 1
[    3.055722] mice: PS/2 mouse device common for all mice
[    3.055936] rtc_cmos 00:02: RTC can wake from S4
[    3.056011] rtc_cmos 00:02: rtc core: registered rtc_cmos as rtc0
[    3.056045] rtc0: alarms up to one month, 114 bytes nvram, hpet irqs
[    3.056311] device-mapper: uevent: version 1.0.3
[    3.056498] device-mapper: ioctl: 4.15.0-ioctl (2009-04-01)
initialised: dm-devel@redhat.com
[    3.056615] device-mapper: multipath: version 1.1.0 loaded
[    3.056620] device-mapper: multipath round-robin: version 1.0.0 loaded
[    3.056890] cpuidle: using governor ladder
[    3.056894] cpuidle: using governor menu
[    3.057659] TCP cubic registered
[    3.057921] NET: Registered protocol family 10
[    3.058727] lo: Disabled Privacy Extensions
[    3.059292] NET: Registered protocol family 17
[    3.059529] PM: Resume from disk failed.
[    3.059551] registered taskstats version 1
[    3.059995]   Magic number: 2:366:326
[    3.060115] rtc_cmos 00:02: setting system clock to 2010-07-27
10:18:38 UTC (1280225918)
[    3.060122] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
[    3.060125] EDD information not available.
[    3.077271] input: AT Translated Set 2 keyboard as
/devices/platform/i8042/serio0/input/input3
[    3.204995] ata1.00: ATAPI: HL-DT-ST DVDRAM XXXXX, A103, max UDMA/33
[    3.223305] ata4.01: ATA-8: XXX WD1001XXXXX, XXXXX, max UDMA/133
[    3.223311] ata4.01: XXXXXXXXXXX sectors, multi 16: LBA48 NCQ (depth 0/32)
[    3.223905] ata3.00: ATA-8: WDC WD1002XXXXX, XXXXX, max UDMA/133
[    3.223911] ata3.00: XXXXXXXXXXX sectors, multi 16: LBA48 NCQ (depth 0/32)
[    3.242817] ata1.00: configured for UDMA/33
[    3.263110] ata3.00: configured for UDMA/133
[    3.263174] ata4.01: configured for UDMA/133
[    3.267721] scsi 0:0:0:0: CD-ROM            HL-DT-ST DVDRAM XXXXX
A103 PQ: 0 ANSI: 5
[    3.273265] sr0: scsi3-mmc drive: 40x/40x writer dvd-ram cd/rw
xa/form2 cdda tray
[    3.273272] Uniform CD-ROM driver Revision: 3.20
[    3.273455] sr 0:0:0:0: Attached scsi CD-ROM sr0
[    3.273559] sr 0:0:0:0: Attached scsi generic sg0 type 5
[    3.273792] scsi 2:0:0:0: Direct-Access     ATA      WDC WD1002XXX0
05.0 PQ: 0 ANSI: 5
[    3.273989] sd 2:0:0:0: Attached scsi generic sg1 type 0
[    3.274170] scsi 3:0:1:0: Direct-Access     ATA      WDC WD1001XXX0
05.0 PQ: 0 ANSI: 5
[    3.274360] sd 3:0:1:0: Attached scsi generic sg2 type 0
[    3.274466] sd 3:0:1:0: [sdb] XXXXXXXXXXX 512-byte logical blocks:
(X.XX XX/XXX XXX)
[    3.274515] sd 2:0:0:0: [sda] XXXXXXXXXXX 512-byte logical blocks:
(X.XX XX/XXX XXX)
[    3.274637] sd 3:0:1:0: [sdb] Write Protect is off
[    3.274642] sd 3:0:1:0: [sdb] Mode Sense: 00 3a 00 00
[    3.274685] sd 2:0:0:0: [sda] Write Protect is off
[    3.274690] sd 2:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    3.274734] sd 3:0:1:0: [sdb] Write cache: enabled, read cache:
enabled, doesn't support DPO or FUA
[    3.274850] sd 2:0:0:0: [sda] Write cache: enabled, read cache:
enabled, doesn't support DPO or FUA
[    3.275202]  sda:
[    3.275309]  sdb: sdb1 sdb2
[    3.286257] sd 3:0:1:0: [sdb] Attached SCSI disk
[    3.287038]  sda1 sda2
[    3.287417] sd 2:0:0:0: [sda] Attached SCSI disk
[    3.486486] Freeing initrd memory: 9607k freed
[    3.492690] Freeing unused kernel memory: 876k freed
[    3.493264] Write protecting the kernel read-only data: 7680k
[    3.524986] udev: starting version 151
[    3.592650] usb 2-1: new low speed USB device using uhci_hcd and address 2
[    3.611879] agpgart-intel 0000:00:00.0: Intel 915G Chipset
[    3.612325] agpgart-intel 0000:00:00.0: detected 32508K stolen memory
[    3.729003] agpgart-intel 0000:00:00.0: AGP aperture is 256M @ 0xd0000000
[    3.749672] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
[    3.749678] e100: Copyright(c) 1999-2006 Intel Corporation
[    3.749747]   alloc irq_desc for 20 on node -1
[    3.749754]   alloc kstat_irqs on node -1
[    3.749768] e100 0000:06:08.0: PCI INT A -> GSI 20 (level, low) -> IRQ 20
[    3.774035] e100 0000:06:08.0: PME# disabled
[    3.774219] usb 2-1: configuration #1 chosen from 1 choice
[    3.782942] e100: eth0: e100_probe: addr 0xff510000, irq 20, MAC
addr 00:XX:XX:XX:XX:XX
[    3.782990]   alloc irq_desc for 21 on node -1
[    3.782994]   alloc kstat_irqs on node -1
[    3.783006] 3c59x 0000:06:00.0: PCI INT A -> GSI 21 (level, low) -> IRQ 21
[    3.783012] 3c59x: Donald Becker and others.
[    3.783020] 0000:06:00.0: 3Com PCI 3c905 Boomerang 100baseTx at
000000000001bc00.
[    3.789356] [drm] Initialized drm 1.1.0 20060810
[    3.830889] i915 0000:00:02.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    3.830898] i915 0000:00:02.0: setting latency timer to 64
[    3.842987] [drm] set up 31M of stolen space
[    3.844011] [drm] initialized overlay support
[    3.850924] usbcore: registered new interface driver hiddev
[    3.863525] input: HID 062a:0001 as
/devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1:1.0/input/input4
[    3.863777] generic-usb 0003:062A:0001.0001: input,hidraw0: USB HID
v1.10 Mouse [HID 062a:0001] on usb-0000:00:1d.0-1/input0
[    3.863821] usbcore: registered new interface driver usbhid
[    3.863880] usbhid: v2.6:USB HID core driver
[    4.024392] fb0: inteldrmfb frame buffer device
[    4.024396] registered panic notifier
[    4.024406] [drm] Initialized i915 1.6.0 20080730 for 0000:00:02.0 on minor 0
[    4.027240] vga16fb: initializing
[    4.027248] vga16fb: mapped to 0xffff8800000a0000
[    4.027257] vga16fb: not registering due to another framebuffer present
[    4.159860] Console: switching to colour frame buffer device 240x90
[    5.211492] xor: automatically using best checksumming function: generic_sse
[    5.260009]    generic_sse:  4654.000 MB/sec
[    5.260012] xor: using function: generic_sse (4654.000 MB/sec)
[    5.265763] device-mapper: dm-raid45: initialized v0.2594b
[    7.298727] ISO 9660 Extensions: Microsoft Joliet Level 3
[    7.359461] ISO 9660 Extensions: RRIP_1991A
[    7.690903] aufs 2-standalone.tree-20091207
[    7.894415] squashfs: version 4.0 (2009/01/31) Phillip Lougher
[   66.277270] udev: starting version 151
[   70.278187] intel_rng: Firmware space is locked read-only. If you can't or
[   70.278191] intel_rng: don't want to disable this in firmware setup, and if
[   70.278194] intel_rng: you are certain that your system has a functional
[   70.278196] intel_rng: RNG, try using the 'no_fwh_detect' option.
[   71.220160] parport_pc 00:07: reported by Plug and Play ACPI
[   71.220202] parport0: PC-style at 0x378, irq 7 [PCSPP,TRISTATE,EPP]
[   72.292606] ppdev: user-space parallel port driver
[   74.597802] eth1:  setting half-duplex.
[   74.598240] ADDRCONF(NETDEV_UP): eth1: link is not ready
[   74.641281] ADDRCONF(NETDEV_UP): eth0: link is not ready
[   74.650159] e100: eth0 NIC Link is Up 100 Mbps Full Duplex
[   74.650636] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   76.063072] HDA Intel 0000:00:1b.0: PCI INT A -> GSI 16 (level,
low) -> IRQ 16
[   76.063127] HDA Intel 0000:00:1b.0: setting latency timer to 64
[   76.391707] input: HDA Digital PCBeep as
/devices/pci0000:00/0000:00:1b.0/input/input5
[   84.730015] eth0: no IPv6 routers present
[   88.239423] lp0: using parport0 (interrupt-driven).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
