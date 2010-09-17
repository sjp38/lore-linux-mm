Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 4287F6B0078
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 20:39:12 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8H0dDKo026098
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 17 Sep 2010 09:39:14 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 927B945DE60
	for <linux-mm@kvack.org>; Fri, 17 Sep 2010 09:39:13 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 729BB45DE4D
	for <linux-mm@kvack.org>; Fri, 17 Sep 2010 09:39:13 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5ADEF1DB803B
	for <linux-mm@kvack.org>; Fri, 17 Sep 2010 09:39:13 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 108DF1DB8037
	for <linux-mm@kvack.org>; Fri, 17 Sep 2010 09:39:13 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: OOM help
In-Reply-To: <20100915120349.GH29041@electro-mechanical.com>
References: <20100915120349.GH29041@electro-mechanical.com>
Message-Id: <20100916164231.3BC3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 17 Sep 2010 09:39:11 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: William Thompson <wt@electro-mechanical.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi William

> Here is the dmesg when the oom kicked in:
> [1557576.330762] Xorg invoked oom-killer: gfp_mask=0xd0, order=0, oomkilladj=0

GFP_KERNEL.

> [1557576.330767] Pid: 6696, comm: Xorg Not tainted 2.6.31.3 #1
> [1557576.330769] Call Trace:
> [1557576.330775]  [<c02679ec>] ? oom_kill_process+0xac/0x250
> [1557576.330777]  [<c0267e57>] ? badness+0x167/0x240
> [1557576.330780]  [<c0268074>] ? __out_of_memory+0x144/0x170
> [1557576.330782]  [<c02680f4>] ? out_of_memory+0x54/0xb0
> [1557576.330785]  [<c026b211>] ? __alloc_pages_nodemask+0x541/0x560
> [1557576.330788]  [<c026b284>] ? __get_free_pages+0x14/0x30
> [1557576.330791]  [<c02a1b62>] ? __pollwait+0xa2/0xf0
> [1557576.330794]  [<c0479ab4>] ? unix_poll+0x14/0xa0
> [1557576.330797]  [<c040a00c>] ? sock_poll+0xc/0x10
> [1557576.330799]  [<c02a12ab>] ? do_select+0x2bb/0x550
> [1557576.330801]  [<c02a1ac0>] ? __pollwait+0x0/0xf0
> [1557576.330804]  [<c02a1bb0>] ? pollwake+0x0/0x80
> [1557576.330806]  [<c02a1bb0>] ? pollwake+0x0/0x80
> [1557576.330808]  [<c02a1bb0>] ? pollwake+0x0/0x80
> [1557576.330810]  [<c02a1bb0>] ? pollwake+0x0/0x80
> [1557576.330812]  [<c02a1bb0>] ? pollwake+0x0/0x80
> [1557576.330814]  [<c02a1bb0>] ? pollwake+0x0/0x80
> [1557576.330816]  [<c02a1bb0>] ? pollwake+0x0/0x80
> [1557576.330818]  [<c02a1bb0>] ? pollwake+0x0/0x80
> [1557576.330821]  [<c02a1bb0>] ? pollwake+0x0/0x80
> [1557576.330823]  [<c02a1bb0>] ? pollwake+0x0/0x80
> [1557576.330825]  [<c02a1bb0>] ? pollwake+0x0/0x80
> [1557576.330827]  [<c02a1bb0>] ? pollwake+0x0/0x80
> [1557576.330829]  [<c02a1bb0>] ? pollwake+0x0/0x80
> [1557576.330831]  [<c02a1bb0>] ? pollwake+0x0/0x80
> [1557576.330833]  [<c02a1bb0>] ? pollwake+0x0/0x80
> [1557576.330835]  [<c02a1bb0>] ? pollwake+0x0/0x80
> [1557576.330837]  [<c02a1bb0>] ? pollwake+0x0/0x80
> [1557576.330839]  [<c02a1bb0>] ? pollwake+0x0/0x80
> [1557576.330841]  [<c02a1730>] ? core_sys_select+0x1f0/0x320
> [1557576.330844]  [<c029f9f3>] ? do_vfs_ioctl+0x3e3/0x610
> [1557576.330847]  [<c024354c>] ? hrtimer_try_to_cancel+0x3c/0x80
> [1557576.330850]  [<c02481a4>] ? getnstimeofday+0x54/0x110
> [1557576.330852]  [<c02a1a3f>] ? sys_select+0x2f/0xb0
> [1557576.330855]  [<c0202f61>] ? syscall_call+0x7/0xb
> [1557576.330857] Mem-Info:
> [1557576.330858] DMA per-cpu:
> [1557576.330860] CPU    0: hi:    0, btch:   1 usd:   0
> [1557576.330861] CPU    1: hi:    0, btch:   1 usd:   0
> [1557576.330863] CPU    2: hi:    0, btch:   1 usd:   0
> [1557576.330864] CPU    3: hi:    0, btch:   1 usd:   0
> [1557576.330865] Normal per-cpu:
> [1557576.330867] CPU    0: hi:  186, btch:  31 usd: 104
> [1557576.330868] CPU    1: hi:  186, btch:  31 usd: 167
> [1557576.330870] CPU    2: hi:  186, btch:  31 usd: 171
> [1557576.330871] CPU    3: hi:  186, btch:  31 usd: 173
> [1557576.330873] HighMem per-cpu:
> [1557576.330874] CPU    0: hi:  186, btch:  31 usd:  24
> [1557576.330875] CPU    1: hi:  186, btch:  31 usd:   1
> [1557576.330877] CPU    2: hi:  186, btch:  31 usd:  23
> [1557576.330878] CPU    3: hi:  186, btch:  31 usd:  17
> [1557576.330881] Active_anon:99096 active_file:75187 inactive_anon:14426
> [1557576.330882]  inactive_file:1117251 unevictable:867 dirty:0 writeback:256 unstable:0
> [1557576.330883]  free:673090 slab:89233 mapped:22358 pagetables:1487 bounce:0
> [1557576.330886] DMA free:1984kB min:88kB low:108kB high:132kB active_anon:0kB inactive_anon:0kB active_file:140kB inactive_file:0kB unevictable:0kB present:15864kB pages_scanned:256 all_unreclaimable? yes
> [1557576.330888] lowmem_reserve[]: 0 478 8104 8104
> [1557576.330892] Normal free:2728kB min:2752kB low:3440kB high:4128kB 
                   active_anon:0kB inactive_anon:0kB active_file:23296kB inactive_file:22748kB unevictable:0kB
                   present:489704kB pages_scanned:72700 all_unreclaimable? yes

present: 500MB
file cache: 50MB
all_unreclaimable: yes

That said, there are two possibility.
 1) your kernel (probably drivers) have memory leak
 2) you are using really lots of GFP_KERNEL memory. and then, you need to switch 64bit kernel


Can you please try latest kernel and try reproduce? I'm curios two point.
1) If latest doesn't OOM, the leak has been fixed already. 2) If the OOM occur,
latest output more detailed information.

But, if you want asap solution, I recommend to try 64bit kernel.


Thanks.


> [1557576.330895] lowmem_reserve[]: 0 0 61012 61012
> [1557576.330899] HighMem free:2687648kB min:512kB low:11492kB high:22476kB active_anon:396384kB inactive_anon:57704kB active_file:277312kB inactive_file:4446256kB unevictable:3468kB present:7809620kB pages_scanned:0 all_unreclaimable? no
> [1557576.330902] lowmem_reserve[]: 0 0 0 0
> [1557576.330905] DMA: 14*4kB 15*8kB 14*16kB 11*32kB 6*64kB 5*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 2032kB
> [1557576.330912] Normal: 166*4kB 0*8kB 3*16kB 28*32kB 8*64kB 3*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 2760kB
> [1557576.330919] HighMem: 2*4kB 2*8kB 1*16kB 0*32kB 6*64kB 6*128kB 521*256kB 3334*512kB 636*1024kB 91*2048kB 2*4096kB = 2687400kB
> [1557576.330927] 1193548 total pagecache pages
> [1557576.330928] 0 pages in swap cache
> [1557576.330930] Swap cache stats: add 0, delete 0, find 0/0
> [1557576.330931] Free swap  = 0kB
> [1557576.330932] Total swap = 0kB
> [1557576.351721] 2162688 pages RAM
> [1557576.351724] 2035202 pages HighMem
> [1557576.351725] 86689 pages reserved
> [1557576.351727] 1221151 pages shared
> [1557576.351728] 241369 pages non-shared
> [1557576.351730] Out of memory: kill process 23372 (slapd) score 4718 or a child
> [1557576.351764] Killed process 23372 (slapd)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
