Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0490A6B005A
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 22:29:28 -0400 (EDT)
Received: by pxi33 with SMTP id 33so474214pxi.12
        for <linux-mm@kvack.org>; Tue, 30 Jun 2009 19:30:23 -0700 (PDT)
Date: Wed, 1 Jul 2009 10:30:19 +0800
From: Wu Fengguang <fengguang.wu@gmail.com>
Subject: Re: Found the commit that causes the OOMs
Message-ID: <20090701023019.GB6356@localhost>
References: <20090628151026.GB25076@localhost> <20090629091741.ab815ae7.minchan.kim@barrios-desktop> <17678.1246270219@redhat.com> <20090629125549.GA22932@localhost> <29432.1246285300@redhat.com> <28c262360906290800v37f91d7av3642b1ad8b5f0477@mail.gmail.com> <30071.1246290885@redhat.com> <1246291007.663.630.camel@macbook.infradead.org> <20090630140512.GA16923@localhost> <28c262360906300850l402e2bb0xca14a2d0571eb3cf@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <28c262360906300850l402e2bb0xca14a2d0571eb3cf@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: David Woodhouse <dwmw2@infradead.org>, David Howells <dhowells@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 01, 2009 at 12:50:42AM +0900, Minchan Kim wrote:
> On Tue, Jun 30, 2009 at 11:05 PM, Wu Fengguang<fengguang.wu@gmail.com> wrote:
> >
> > More data: I boot 2.6.30-rc1 with mem=1G and enabled 1GB swap and run msgctl11.
> >
> > It goes OOM at the 2nd run. They are very interesting numbers: memory leaked?
> 
> Hmm. It's very serious and another problem since this system have swap
> device and it's not full.

Yes.

> Can you reproduce it easily ?

Not always. It runs OK in the first run (after fresh boot).
At the second run, it may OOM, or lockup (dmesg in another email).

> I want to reproduce it in my system.
> 
> Did you ran only msgctl11 not all LTP test ?
> Just default parameter ? ex) $ ./testcases/bin/msgctl11

Yes, I run it standalone with no parameters.

> 2nd run ? You mean you execute msgctl11 two time in order ?
> I mean after first test is finished successfully and OOM happens
> second test before ending successfully ?

Yes, to run it two times after fresh boot.
Because the first run seem to always succeed.

Thanks,
Fengguang

> 
> > A  A  A  A [ 2259.825958] msgctl11 invoked oom-killer: gfp_mask=0x84d0, order=0, oom_adj=0
> > A  A  A  A [ 2259.828092] Pid: 29657, comm: msgctl11 Not tainted 2.6.31-rc1 #22
> > A  A  A  A [ 2259.830505] Call Trace:
> > A  A  A  A [ 2259.832010] A [<ffffffff8156f366>] ? _spin_unlock+0x26/0x30
> > A  A  A  A [ 2259.834219] A [<ffffffff810c8b26>] oom_kill_process+0x176/0x270
> > A  A  A  A [ 2259.837603] A [<ffffffff810c8def>] ? badness+0x18f/0x300
> > A  A  A  A [ 2259.839906] A [<ffffffff810c9095>] __out_of_memory+0x135/0x170
> > A  A  A  A [ 2259.842035] A [<ffffffff810c91c5>] out_of_memory+0xf5/0x180
> > A  A  A  A [ 2259.844270] A [<ffffffff810cd86c>] __alloc_pages_nodemask+0x6ac/0x6c0
> > A  A  A  A [ 2259.846743] A [<ffffffff810f8fa8>] alloc_pages_current+0x78/0x100
> > A  A  A  A [ 2259.849083] A [<ffffffff81033515>] pte_alloc_one+0x15/0x50
> > A  A  A  A [ 2259.851282] A [<ffffffff810e0eda>] __pte_alloc+0x2a/0xf0
> > A  A  A  A [ 2259.853454] A [<ffffffff810e16e2>] handle_mm_fault+0x742/0x830
> > A  A  A  A [ 2259.855793] A [<ffffffff815725cb>] do_page_fault+0x1cb/0x330
> > A  A  A  A [ 2259.858033] A [<ffffffff8156fdf5>] page_fault+0x25/0x30
> > A  A  A  A [ 2259.860301] Mem-Info:
> > A  A  A  A [ 2259.861706] Node 0 DMA per-cpu:
> > A  A  A  A [ 2259.862523] CPU A  A 0: hi: A  A 0, btch: A  1 usd: A  0
> > A  A  A  A [ 2259.864454] CPU A  A 1: hi: A  A 0, btch: A  1 usd: A  0
> > A  A  A  A [ 2259.866608] Node 0 DMA32 per-cpu:
> > A  A  A  A [ 2259.867404] CPU A  A 0: hi: A 186, btch: A 31 usd: 197
> > A  A  A  A [ 2259.869283] CPU A  A 1: hi: A 186, btch: A 31 usd: 175
> > A  A  A  A [ 2259.870511] Active_anon:0 active_file:11 inactive_anon:0
> >
> > zero anon pages!
> >
> > A  A  A  A [ 2259.870512] A inactive_file:0 unevictable:0 dirty:0 writeback:0 unstable:0
> > A  A  A  A [ 2259.870513] A free:1986 slab:42170 mapped:96 pagetables:59427 bounce:0
> > A  A  A  A [ 2259.877722] Node 0 DMA free:3976kB min:56kB low:68kB high:84kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:15164kB pages_scanned:429 all_unreclaimable? no
> > A  A  A  A [ 2259.883804] lowmem_reserve[]: 0 982 982 982
> > A  A  A  A [ 2259.885814] Node 0 DMA32 free:3968kB min:3980kB low:4972kB high:5968kB active_anon:0kB inactive_anon:0kB active_file:44kB inactive_file:0kB unevictable:0kB present:1005984kB pages_scanned:152 all_unreclaimable? no
> > A  A  A  A [ 2259.890958] lowmem_reserve[]: 0 0 0 0
> > A  A  A  A [ 2259.893183] Node 0 DMA: 4*4kB 3*8kB 2*16kB 0*32kB 1*64kB 2*128kB 0*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 3976kB
> > A  A  A  A [ 2259.897406] Node 0 DMA32: 334*4kB 77*8kB 24*16kB 27*32kB 10*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3968kB
> > A  A  A  A [ 2259.902753] 625 total pagecache pages
> > A  A  A  A [ 2259.903623] 454 pages in swap cache
> > A  A  A  A [ 2259.905299] Swap cache stats: add 95129, delete 94675, find 55783/67607
> > A  A  A  A [ 2259.908858] Free swap A = 1041232kB
> > A  A  A  A [ 2259.909618] Total swap = 1048568kB
> >
> > swap far from full!
> >
> > A  A  A  A [ 2259.919456] 262144 pages RAM
> > A  A  A  A [ 2259.921071] 12513 pages reserved
> > A  A  A  A [ 2259.922790] 314212 pages shared
> > A  A  A  A [ 2259.923548] 165757 pages non-shared
> > A  A  A  A [ 2259.925234] Out of memory: kill process 20791 (msgctl11) score 2280094 or a child
> > A  A  A  A [ 2259.928982] Killed process 21946 (msgctl11)
> >
> >
> 
> 
> 
> -- 
> Kinds regards,
> Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
