Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id F3F206B006A
	for <linux-mm@kvack.org>; Sun,  1 Nov 2009 23:24:15 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA24ODic019940
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 2 Nov 2009 13:24:13 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9EB2E45DE4F
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 13:24:12 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3578145DE51
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 13:24:12 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id DB980E18019
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 13:24:11 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E61861DB8040
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 13:24:06 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: OOM killer, page fault
In-Reply-To: <20091030063216.GA30712@gamma.logic.tuwien.ac.at>
References: <20091030063216.GA30712@gamma.logic.tuwien.ac.at>
Message-Id: <20091102005218.8352.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  2 Nov 2009 13:24:06 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Norbert Preining <preining@logic.at>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

(Cc to linux-mm)

Wow, this is very strange log.

> Dear all,
> 
> (please Cc)
> 
> With 2.6.32-rc5 I got that one:
> [13832.210068] Xorg invoked oom-killer: gfp_mask=0x0, order=0, oom_adj=0

order = 0

> [13832.210073] Pid: 11220, comm: Xorg Not tainted 2.6.32-rc5 #2
> [13832.210075] Call Trace:
> [13832.210081]  [<ffffffff8134120a>] ? _spin_unlock+0x23/0x2f
> [13832.210085]  [<ffffffff8107cf46>] ? oom_kill_process+0x78/0x236
> [13832.210088]  [<ffffffff8107d5ba>] ? __out_of_memory+0x12f/0x146
> [13832.210091]  [<ffffffff8107d6be>] ? pagefault_out_of_memory+0x54/0x82
> [13832.210094]  [<ffffffff81341177>] ? _spin_unlock_irqrestore+0x25/0x31
> [13832.210098]  [<ffffffff8102644d>] ? mm_fault_error+0x39/0xe6
> [13832.210101]  [<ffffffff810af3ea>] ? do_vfs_ioctl+0x443/0x47b
> [13832.210103]  [<ffffffff81026759>] ? do_page_fault+0x25f/0x27b
> [13832.210106]  [<ffffffff8134161f>] ? page_fault+0x1f/0x30
> [13832.210108] Mem-Info:
> [13832.210109] DMA per-cpu:
> [13832.210111] CPU    0: hi:    0, btch:   1 usd:   0
> [13832.210113] CPU    1: hi:    0, btch:   1 usd:   0
> [13832.210114] DMA32 per-cpu:
> [13832.210116] CPU    0: hi:  186, btch:  31 usd: 165
> [13832.210117] CPU    1: hi:  186, btch:  31 usd: 177
> [13832.210119] Normal per-cpu:
> [13832.210120] CPU    0: hi:  186, btch:  31 usd: 143
> [13832.210122] CPU    1: hi:  186, btch:  31 usd: 159
> [13832.210128] active_anon:465239 inactive_anon:178856 isolated_anon:96
> [13832.210129]  active_file:120044 inactive_file:120889 isolated_file:34

but the system has plenty droppable cache.

Umm, Is this reproducable?
Typically such strange log was caused by corruptted ram. can you please
check your memory correctness?


> [13832.210130]  unevictable:32076 dirty:136955 writeback:1178 unstable:0 buffer:32965
> [13832.210131]  free:6932 slab_reclaimable:23740 slab_unreclaimable:11776
> [13832.210132]  mapped:41869 shmem:127673 pagetables:7320 bounce:0
> [13832.210138] DMA free:15784kB min:28kB low:32kB high:40kB active_anon:0kB inactive_anon:0kB active_file:24kB inactive_file:132kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15364kB mlocked:0kB dirty:60kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:16kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> [13832.210142] lowmem_reserve[]: 0 2931 3941 3941
> [13832.210150] DMA32 free:9928kB min:5960kB low:7448kB high:8940kB active_anon:1527548kB inactive_anon:382016kB active_file:345724kB inactive_file:348528kB unevictable:127864kB isolated(anon):256kB isolated(file):0kB present:3001852kB mlocked:127864kB dirty:389520kB writeback:3192kB mapped:119544kB shmem:301556kB slab_reclaimable:62476kB slab_unreclaimable:22472kB kernel_stack:320kB pagetables:6692kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:448 all_unreclaimable? no
> [13832.210155] lowmem_reserve[]: 0 0 1010 1010
> [13832.210161] Normal free:2016kB min:2052kB low:2564kB high:3076kB active_anon:333408kB inactive_anon:333408kB active_file:134428kB inactive_file:134896kB unevictable:440kB isolated(anon):128kB isolated(file):136kB present:1034240kB mlocked:440kB dirty:158240kB writeback:1520kB mapped:47932kB shmem:209136kB slab_reclaimable:32468kB slab_unreclaimable:24632kB kernel_stack:2072kB pagetables:22588kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:192 all_unreclaimable? no
> [13832.210166] lowmem_reserve[]: 0 0 0 0
> [13832.210169] DMA: 2*4kB 2*8kB 1*16kB 2*32kB 1*64kB 2*128kB 2*256kB 1*512kB 2*1024kB 2*2048kB 2*4096kB = 15784kB
> [13832.210177] DMA32: 624*4kB 1*8kB 11*16kB 6*32kB 1*64kB 8*128kB 5*256kB 1*512kB 0*1024kB 0*2048kB 1*4096kB = 9848kB
> [13832.210184] Normal: 504*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 2016kB
> [13832.210191] 374966 total pagecache pages
> [13832.210192] 6328 pages in swap cache
> [13832.210194] Swap cache stats: add 147686, delete 141358, find 119392/120966
> [13832.210195] Free swap  = 8661548kB
> [13832.210197] Total swap = 8851804kB
> [13832.225488] 1048576 pages RAM
> [13832.225491] 73094 pages reserved
> [13832.225492] 695291 pages shared
> [13832.225493] 352255 pages non-shared
> [13832.225496] Out of memory: kill process 11292 (gnome-session) score 500953 or a child
> [13832.225498] Killed process 11569 (xscreensaver)
> 
> 
> After that I managed to get my system runing normally on, restarting X,
> all runs since then quite fine.
> 
> Is that something I should be nervous about?

This obviously indicate kernel-bug or hw-corrupt. I'm not sure which happen ;)



> Thanks a lot and all the best
> 
> Norbert



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
