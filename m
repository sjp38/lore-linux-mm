Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 478A86B02AE
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 07:14:41 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6RBEc1C015360
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 27 Jul 2010 20:14:38 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id ECACA45DE51
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 20:14:37 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C84ED45DE4F
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 20:14:37 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A5E7A1DB8038
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 20:14:37 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 553661DB803E
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 20:14:37 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: PROBLEM: oom killer and swap weirdness on 2.6.3* kernels
In-Reply-To: <AANLkTinT_W4Zfg8xcpKXMpqTAomdVBdHve7VqamdSr4o@mail.gmail.com>
References: <AANLkTikjJ0giM+MpzNu3e0NQN=JLMviPT8UPHdZqGGpz@mail.gmail.com> <AANLkTinT_W4Zfg8xcpKXMpqTAomdVBdHve7VqamdSr4o@mail.gmail.com>
Message-Id: <20100727200804.2F40.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Tue, 27 Jul 2010 20:14:36 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: dave b <db.pub.mail@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On 27 July 2010 18:09, dave b <db.pub.mail@gmail.com> wrote:
> > On 27 July 2010 16:09, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> >>> > Do you mean the issue will be gone if disabling intel graphics?
> >>> It may be a general issue or it could just be specific :)
> >
> > I will try with the latest ubuntu and report how that goes (that will
> > be using fairly new xorg etc.) it is likely to be hidden issue just
> > with the intel graphics driver. However, my concern is that it isn't -
> > and it is about how shared graphics memory is handled :)
> 
> 
> Ok my desktop still stalled and no oom killer was invoked when I added
> swap to a live-cd of 10.04 amd64.
> 
> *Without* *swap* *on* - the oom killer was invoked - here is a copy of it.

This stack seems similar following bug. can you please try to disable intel graphics
driver?

https://bugzilla.kernel.org/show_bug.cgi?id=14933


> [  298.180542] Xorg invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=0
> [  298.180553] Xorg cpuset=/ mems_allowed=0
> [  298.180560] Pid: 3808, comm: Xorg Not tainted 2.6.32-21-generic #32-Ubuntu
> [  298.180564] Call Trace:
> [  298.180583]  [<ffffffff810b37cd>] ? cpuset_print_task_mems_allowed+0x9d/0xb0
> [  298.180595]  [<ffffffff810f64f4>] oom_kill_process+0xd4/0x2f0
> [  298.180603]  [<ffffffff810f6ab0>] ? select_bad_process+0xd0/0x110
> [  298.180609]  [<ffffffff810f6b48>] __out_of_memory+0x58/0xc0
> [  298.180616]  [<ffffffff810f6cde>] out_of_memory+0x12e/0x1a0
> [  298.180626]  [<ffffffff81540c9e>] ? _spin_lock+0xe/0x20
> [  298.180633]  [<ffffffff810f9d21>] __alloc_pages_slowpath+0x511/0x580
> [  298.180641]  [<ffffffff810f9eee>] __alloc_pages_nodemask+0x15e/0x1a0
> [  298.180650]  [<ffffffff8112ca57>] alloc_pages_current+0x87/0xd0
> [  298.180657]  [<ffffffff810f8e0e>] __get_free_pages+0xe/0x50
> [  298.180666]  [<ffffffff81154994>] __pollwait+0xb4/0xf0
> [  298.180673]  [<ffffffff814e09a5>] unix_poll+0x25/0xc0
> [  298.180682]  [<ffffffff81449bea>] sock_poll+0x1a/0x20
> [  298.180688]  [<ffffffff811545b2>] do_select+0x3a2/0x6d0
> [  298.180696]  [<ffffffff811548e0>] ? __pollwait+0x0/0xf0
> [  298.180702]  [<ffffffff811549d0>] ? pollwake+0x0/0x60
> [  298.180708]  [<ffffffff811549d0>] ? pollwake+0x0/0x60
> [  298.180714]  [<ffffffff811549d0>] ? pollwake+0x0/0x60
> [  298.180721]  [<ffffffff811549d0>] ? pollwake+0x0/0x60
> [  298.180727]  [<ffffffff811549d0>] ? pollwake+0x0/0x60
> [  298.180732]  [<ffffffff811549d0>] ? pollwake+0x0/0x60
> [  298.180737]  [<ffffffff811549d0>] ? pollwake+0x0/0x60
> [  298.180741]  [<ffffffff811549d0>] ? pollwake+0x0/0x60
> [  298.180745]  [<ffffffff811549d0>] ? pollwake+0x0/0x60
> [  298.180749]  [<ffffffff811550ba>] core_sys_select+0x18a/0x2c0
> [  298.180777]  [<ffffffffa001eced>] ? drm_ioctl+0x13d/0x480 [drm]
> [  298.180784]  [<ffffffff81085320>] ? autoremove_wake_function+0x0/0x40
> [  298.180790]  [<ffffffff810397a9>] ? default_spin_lock_flags+0x9/0x10
> [  298.180795]  [<ffffffff81540bbf>] ? _spin_lock_irqsave+0x2f/0x40
> [  298.180800]  [<ffffffff81019e89>] ? read_tsc+0x9/0x20
> [  298.180805]  [<ffffffff8108f9c9>] ? ktime_get_ts+0xa9/0xe0
> [  298.180810]  [<ffffffff81155447>] sys_select+0x47/0x110
> [  298.180816]  [<ffffffff810131b2>] system_call_fastpath+0x16/0x1b
> [  298.180819] Mem-Info:
> [  298.180822] Node 0 DMA per-cpu:
> [  298.180827] CPU    0: hi:    0, btch:   1 usd:   0
> [  298.180830] CPU    1: hi:    0, btch:   1 usd:   0
> [  298.180832] Node 0 DMA32 per-cpu:
> [  298.180837] CPU    0: hi:  186, btch:  31 usd:  60
> [  298.180839] CPU    1: hi:  186, btch:  31 usd: 137
> [  298.180845] active_anon:374344 inactive_anon:81753 isolated_anon:0
> [  298.180847]  active_file:7038 inactive_file:7089 isolated_file:0
> [  298.180848]  unevictable:0 dirty:0 writeback:0 unstable:0
> [  298.180849]  free:3399 slab_reclaimable:4226 slab_unreclaimable:4383
> [  298.180851]  mapped:13010 shmem:45284 pagetables:5496 bounce:0
> [  298.180854] Node 0 DMA free:7920kB min:40kB low:48kB high:60kB
> active_anon:3880kB inactive_anon:4096kB active_file:0kB
> inactive_file:0kB unevictable:0kB isolated(anon):0kB
> isolated(file):0kB present:15348kB mlocked:0kB dirty:0kB writeback:0kB
> mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:8kB
> kernel_stack:0kB pagetables:16kB unstable:0kB bounce:0kB
> writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
> [  298.180866] lowmem_reserve[]: 0 1971 1971 1971
> [  298.180871] Node 0 DMA32 free:5676kB min:5660kB low:7072kB
> high:8488kB active_anon:1493496kB inactive_anon:322916kB
> active_file:28152kB inactive_file:28356kB unevictable:0kB
> isolated(anon):0kB isolated(file):0kB present:2019172kB mlocked:0kB
> dirty:0kB writeback:0kB mapped:52040kB shmem:181136kB
> slab_reclaimable:16904kB slab_unreclaimable:17524kB
> kernel_stack:2096kB pagetables:21968kB unstable:0kB bounce:0kB
> writeback_tmp:0kB pages_scanned:41088 all_unreclaimable? no
> [  298.180884] lowmem_reserve[]: 0 0 0 0
> [  298.180889] Node 0 DMA: 4*4kB 2*8kB 1*16kB 2*32kB 2*64kB 2*128kB
> 1*256kB 2*512kB 2*1024kB 2*2048kB 0*4096kB = 7920kB
> [  298.180904] Node 0 DMA32: 397*4kB 1*8kB 1*16kB 1*32kB 1*64kB
> 1*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 5676kB
> [  298.180918] 59413 total pagecache pages
> [  298.180920] 0 pages in swap cache
> [  298.180923] Swap cache stats: add 0, delete 0, find 0/0
> [  298.180925] Free swap  = 0kB
> [  298.180927] Total swap = 0kB
> [  298.188124] 515887 pages RAM
> [  298.188127] 9764 pages reserved
> [  298.188129] 108553 pages shared
> [  298.188131] 467319 pages non-shared
> [  298.188136] Out of memory: kill process 3821 (gnome-session) score
> 503983 or a child
> [  298.188141] Killed process 3855 (ssh-agent)





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
