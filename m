Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 985A06B005C
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 10:21:24 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20090629125549.GA22932@localhost>
References: <20090629125549.GA22932@localhost> <26537.1246086769@redhat.com> <20090627125412.GA1667@cmpxchg.org> <20090628113246.GA18409@localhost> <28c262360906280630n557bb182n5079e33d21ea4a83@mail.gmail.com> <28c262360906280636l93130ffk14086314e2a6dcb7@mail.gmail.com> <20090628142239.GA20986@localhost> <2f11576a0906280801w417d1b9fpe10585b7a641d41b@mail.gmail.com> <20090628151026.GB25076@localhost> <20090629091741.ab815ae7.minchan.kim@barrios-desktop> <17678.1246270219@redhat.com> 
Subject: Re: Found the commit that causes the OOMs
Date: Mon, 29 Jun 2009 15:21:40 +0100
Message-ID: <29432.1246285300@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: dhowells@redhat.com, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes,
                         Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

Wu Fengguang <fengguang.wu@intel.com> wrote:

> Sorry! This one compiles OK:

Sadly that doesn't seem to work either:

msgctl11 invoked oom-killer: gfp_mask=0x200da, order=0, oom_adj=0
msgctl11 cpuset=/ mems_allowed=0
Pid: 30858, comm: msgctl11 Not tainted 2.6.31-rc1-cachefs #146
Call Trace:
 [<ffffffff8107207e>] ? oom_kill_process.clone.0+0xa9/0x245
 [<ffffffff81072345>] ? __out_of_memory+0x12b/0x142
 [<ffffffff810723c6>] ? out_of_memory+0x6a/0x94
 [<ffffffff81074a90>] ? __alloc_pages_nodemask+0x42e/0x51d
 [<ffffffff81080843>] ? do_wp_page+0x2c6/0x5f5
 [<ffffffff810820c1>] ? handle_mm_fault+0x5dd/0x62f
 [<ffffffff81022c32>] ? do_page_fault+0x1f8/0x20d
 [<ffffffff812e069f>] ? page_fault+0x1f/0x30
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd:  38
CPU    1: hi:  186, btch:  31 usd: 106
Active_anon:75040 active_file:0 inactive_anon:2031
 inactive_file:0 unevictable:0 dirty:0 writeback:0 unstable:0
 free:1951 slab:41499 mapped:301 pagetables:60674 bounce:0
DMA free:3932kB min:60kB low:72kB high:88kB active_anon:2868kB inactive_anon:384kB active_file:0kB inactive_file:0kB unevictable:0kB present:15364kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 968 968 968
DMA32 free:3872kB min:3948kB low:4932kB high:5920kB active_anon:297292kB inactive_anon:7740kB active_file:0kB inactive_file:0kB unevictable:0kB present:992032kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 7*4kB 0*8kB 0*16kB 0*32kB 1*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 3932kB
DMA32: 500*4kB 2*8kB 0*16kB 0*32kB 1*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 3872kB
1928 total pagecache pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  = 0kB
Total swap = 0kB
255744 pages RAM
5589 pages reserved
238251 pages shared
216210 pages non-shared
Out of memory: kill process 25221 (msgctl11) score 130560 or a child
Killed process 26379 (msgctl11)


Is there any extra debugging I can put in to get more information out of the
OOM?

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
