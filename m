Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 438E78D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 21:03:11 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 033773EE0BD
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 11:03:06 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D618C45DE4F
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 11:03:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id BBE5E45DE52
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 11:03:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AB2D1E78003
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 11:03:05 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A2281DB803E
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 11:03:05 +0900 (JST)
Date: Thu, 3 Mar 2011 10:56:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: 2.6.38-rc7, OOM behaviour?
Message-Id: <20110303105648.ff1dd61e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTine5sru_JsK1LmRVa9fwxjPsaDdZUTFPCBi6A+c@mail.gmail.com>
References: <AANLkTine5sru_JsK1LmRVa9fwxjPsaDdZUTFPCBi6A+c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathias =?UTF-8?B?QnVyw6lu?= <mathias.buren@gmail.com>
Cc: linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, 2 Mar 2011 19:33:06 +0000
Mathias BurA(C)n <mathias.buren@gmail.com> wrote:

> Hi,
> 
> (please cc as not subscribed)
> 
> Ubuntu 10.10, 2.6.37-rc8, Core2Duo laptop, 6GB DDR2, Intel 160GB SSD.
> 
> I wanted to see what happens when I exhaust the memory of my system.
> It's got 6GB ram and I created a 1GB swap with
> http://code.google.com/p/compcache/ . To use more memory I launched
> google-chrome processes, each with 25 tabs containing various sites
> etc. When I reached 11 Google Chrome windows each with 25 tabs I maxed
> out the memory, and things became real slow (sluggish mouse pointer,
> system generally not responding) and the "HDD"  activity light was
> pretty constant.
> 
> I don't have any on disk swap.
> 
> I couldn't recovery the system at this point (it had stopped
> responding, no HDD indicator, no mouse pointer movement), so I had to
> reboot it using SysRq+b. This is what I saw in the kernel log after
> reboot:
> 

Hmm, then, your keyboard works. In that case, I'll try to see console
by...(Ctrl+Alt+F1 ?). And check what process is alive.
(Or Sysrq+t)

There are tend to be some cases, for example, X-window is killed or
a program for mouse is dead.



> [snip]
> Mar  2 18:34:26 hostname kernel: [22039.152074] [18915]  1000 18915
> 90784     7427   0       7           411 chrome
> Mar  2 18:34:26 hostname kernel: [22039.152077] [19766]  1000 19766
> 63357     1196   0       0             0 gnome-terminal
> Mar  2 18:34:26 hostname kernel: [22039.152081] [19777]  1000 19777
>  3634       41   0       0             0 gnome-pty-helpe
> Mar  2 18:34:26 hostname kernel: [22039.152084] [19778]  1000 19778
>  5825      793   0       0             0 bash
> Mar  2 18:34:26 hostname kernel: [22039.152087] [19840]  1000 19840
>  2871      131   0       0             0 watch
> Mar  2 18:34:26 hostname kernel: [22039.152090] [20136]  1000 20136
> 93107     3997   0      10           588 chrome
> Mar  2 18:34:26 hostname kernel: [22039.152093] Out of memory: Kill
> process 20136 (chrome) score 590 or sacrifice child
> Mar  2 18:34:26 hostname kernel: [22039.152097] Killed process 20136
> (chrome) total-vm:372428kB, anon-rss:15556kB, file-rss:432kB
> Mar  2 18:34:32 hostname kernel: [22042.872291] chrome invoked
> oom-killer: gfp_mask=0x84d0, order=0, oom_adj=0, oom_score_adj=0
> Mar  2 18:34:36 hostname kernel: [22042.872295] chrome cpuset=/ mems_allowed=0
> Mar  2 18:34:38 hostname kernel: [22042.872298] Pid: 16321, comm:
> chrome Tainted: P            2.6.38-rc7 #1
> Mar  2 18:34:38 hostname kernel: [22042.872300] Call Trace:
> Mar  2 18:34:38 hostname kernel: [22042.872308]  [<ffffffff810b2ca2>]
> ? dump_header+0xa2/0x230
> Mar  2 18:34:38 hostname kernel: [22042.872312]  [<ffffffff81205f79>]
> ? apparmor_capable+0x29/0xa0
> Mar  2 18:34:38 hostname kernel: [22042.872317]  [<ffffffff811d40b6>]
> ? security_real_capable_noaudit+0x36/0x70
> Mar  2 18:34:38 hostname kernel: [22042.872320]  [<ffffffff810b31ce>]
> ? oom_kill_process+0x9e/0x290
> Mar  2 18:34:38 hostname kernel: [22042.872323]  [<ffffffff810b3678>]
> ? out_of_memory+0x2b8/0x3d0
> Mar  2 18:34:38 hostname kernel: [22042.872325]  [<ffffffff810b8028>]
> ? __alloc_pages_nodemask+0x848/0x860
> Mar  2 18:34:38 hostname kernel: [22042.872330]  [<ffffffff810e7e64>]
> ? alloc_pages_current+0x94/0x110
> Mar  2 18:34:38 hostname kernel: [22042.872333]  [<ffffffff8102ad9e>]
> ? pte_alloc_one+0xe/0x30
> Mar  2 18:34:38 hostname kernel: [22042.872336]  [<ffffffff810cb2f6>]
> ? __pte_alloc+0x26/0xd0
> Mar  2 18:34:38 hostname kernel: [22042.872339]  [<ffffffff810cec0e>]
> ? handle_mm_fault+0xee/0x1e0
> Mar  2 18:34:38 hostname kernel: [22042.872342]  [<ffffffff814b5227>]
> ? do_page_fault+0x1a7/0x4b0
> Mar  2 18:34:38 hostname kernel: [22042.872346]  [<ffffffff81138f21>]
> ? sys_epoll_wait+0xb1/0x420
> Mar  2 18:34:38 hostname kernel: [22042.872350]  [<ffffffff8103a970>]
> ? default_wake_function+0x0/0x20
> Mar  2 18:34:38 hostname kernel: [22042.872354]  [<ffffffff814b2a0f>]
> ? page_fault+0x1f/0x30
> Mar  2 18:34:38 hostname kernel: [22042.872356] Mem-Info:
> Mar  2 18:34:38 hostname kernel: [22042.872357] Node 0 DMA per-cpu:
> Mar  2 18:34:38 hostname kernel: [22042.872359] CPU    0: hi:    0,
> btch:   1 usd:   0
> Mar  2 18:34:38 hostname kernel: [22042.872361] CPU    1: hi:    0,
> btch:   1 usd:   0
> Mar  2 18:34:38 hostname kernel: [22042.872362] Node 0 DMA32 per-cpu:
> Mar  2 18:34:38 hostname kernel: [22042.872365] CPU    0: hi:  186,
> btch:  31 usd:  30
> Mar  2 18:34:38 hostname kernel: [22042.872366] CPU    1: hi:  186,
> btch:  31 usd:   0
> Mar  2 18:34:38 hostname kernel: [22042.872367] Node 0 Normal per-cpu:
> Mar  2 18:34:38 hostname kernel: [22042.872369] CPU    0: hi:  186,
> btch:  31 usd:  63
> Mar  2 18:34:38 hostname kernel: [22042.872371] CPU    1: hi:  186,
> btch:  31 usd:   0
> Mar  2 18:34:38 hostname kernel: [22042.872375] active_anon:1116980
> inactive_anon:242817 isolated_anon:0
> Mar  2 18:34:38 hostname kernel: [22042.872376]  active_file:507
> inactive_file:689 isolated_file:11
> Mar  2 18:34:38 hostname kernel: [22042.872377]  unevictable:30
> dirty:0 writeback:17 unstable:0
> Mar  2 18:34:38 hostname kernel: [22042.872377]  free:8848
> slab_reclaimable:3286 slab_unreclaimable:8905
> Mar  2 18:34:38 hostname kernel: [22042.872378]  mapped:8639
> shmem:6657 pagetables:15118 bounce:0
> Mar  2 18:34:38 hostname kernel: [22042.872380] Node 0 DMA
> free:15452kB min:24kB low:28kB high:36kB active_anon:0kB
> inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB
> isolated(anon):0kB isolated(file):0kB present:15684kB mlocked:0kB
> dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB
> slab_unreclaimable:424kB kernel_stack:0kB pagetables:0kB unstable:0kB
> bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
> Mar  2 18:34:38 hostname kernel: [22042.872388] lowmem_reserve[]: 0
> 3510 6035 6035
> Mar  2 18:34:38 hostname kernel: [22042.872391] Node 0 DMA32
> free:15856kB min:5776kB low:7220kB high:8664kB active_anon:2916400kB
> inactive_anon:583368kB active_file:792kB inactive_file:1192kB
> unevictable:0kB isolated(anon):0kB isolated(file):44kB
> present:3594900kB mlocked:0kB dirty:0kB writeback:24kB mapped:14068kB
> shmem:14344kB slab_reclaimable:1576kB slab_unreclaimable:9256kB
> kernel_stack:1112kB pagetables:26496kB unstable:0kB bounce:0kB
> writeback_tmp:0kB pages_scanned:507 all_unreclaimable? no
> Mar  2 18:34:38 hostname kernel: [22042.872399] lowmem_reserve[]: 0 0 2524 2524
> Mar  2 18:34:38 hostname kernel: [22042.872402] Node 0 Normal
> free:4084kB min:4152kB low:5188kB high:6228kB active_anon:1551520kB
> inactive_anon:387900kB active_file:1236kB inactive_file:1564kB
> unevictable:120kB isolated(anon):0kB isolated(file):0kB
> present:2585592kB mlocked:112kB dirty:0kB writeback:44kB
> mapped:20488kB shmem:12284kB slab_reclaimable:11568kB
> slab_unreclaimable:25940kB kernel_stack:2864kB pagetables:33976kB
> unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:400
> all_unreclaimable? no
> Mar  2 18:34:38 hostname kernel: [22042.872411] lowmem_reserve[]: 0 0 0 0
> Mar  2 18:34:38 hostname kernel: [22042.872414] Node 0 DMA: 1*4kB
> 1*8kB 1*16kB 0*32kB 1*64kB 0*128kB 0*256kB 0*512kB 1*1024kB 1*2048kB
> 3*4096kB = 15452kB
> Mar  2 18:34:38 hostname kernel: [22042.872421] Node 0 DMA32: 126*4kB
> 103*8kB 78*16kB 29*32kB 11*64kB 9*128kB 9*256kB 4*512kB 2*1024kB
> 0*2048kB 1*4096kB = 15856kB
> Mar  2 18:34:38 hostname kernel: [22042.872429] Node 0 Normal: 533*4kB
> 14*8kB 3*16kB 1*32kB 1*64kB 2*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB
> 0*4096kB = 4180kB
> Mar  2 18:34:38 hostname kernel: [22042.872436] 60090 total pagecache pages
> Mar  2 18:34:38 hostname kernel: [22042.872437] 52166 pages in swap cache
> Mar  2 18:34:38 hostname kernel: [22042.872439] Swap cache stats: add
> 753370, delete 701204, find 73773/125774
> Mar  2 18:34:38 hostname kernel: [22042.872441] Free swap  = 0kB
> Mar  2 18:34:38 hostname kernel: [22042.872442] Total swap = 1048572kB
> Mar  2 18:34:38 hostname kernel: [22042.898366] 1572848 pages RAM
> Mar  2 18:34:38 hostname kernel: [22042.898368] 41030 pages reserved
> Mar  2 18:34:38 hostname kernel: [22042.898369] 36046 pages shared
> Mar  2 18:34:38 hostname kernel: [22042.898370] 1512687 pages non-shared
> Mar  2 18:34:38 hostname kernel: [22042.898372] [ pid ]   uid  tgid
> total_vm      rss cpu oom_adj oom_score_adj name
> Mar  2 18:34:38 hostname kernel: [22042.898382] [  289]     0   289
>  4241       39   1       0             0 upstart-udev-br
> Mar  2 18:34:38 hostname kernel: [22042.898386] [  297]     0   297
>  4304       36   1     -17         -1000 udevd
> Mar  2 18:34:38 hostname kernel: [22042.898391] [  533]     0   533
>  2963       40   0       0             0 lt-ntfs
> [snip]
> 
> Is this normal?
> 

The log itself seems normal to me, you exhausted 1GB swap(of compcache).
But I'm not sure Sysrq+b can sync kernel's log buffer and /var/logm/message
contents. So, there may be something not printed (because rsyslogd was
blocked by something) and some other process were killed.

kernel developpers tend to take serial console log. In these days,
doing tests on kvm will allow you to get serial output easily.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
