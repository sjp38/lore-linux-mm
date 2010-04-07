Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 71B6A6B01E3
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 04:52:36 -0400 (EDT)
Date: Wed, 7 Apr 2010 16:52:30 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: 32GB SSD on USB1.1 P3/700 == ___HELL___ (2.6.34-rc3)
Message-ID: <20100407085230.GA21644@localhost>
References: <20100404221349.GA18036@rhlx01.hs-esslingen.de> <20100405105319.GA16528@rhlx01.hs-esslingen.de> <20100407070050.GA10527@localhost> <h2h28c262361004070139r7a729959od486bb2a022afd4b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <h2h28c262361004070139r7a729959od486bb2a022afd4b@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andreas Mohr <andi@lisas.de>, Jens Axboe <axboe@kernel.dk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> >> active_anon:34886 inactive_anon:41460 isolated_anon:1
> >> A active_file:13576 inactive_file:27884 isolated_file:65
> >> A unevictable:0 dirty:4788 writeback:5675 unstable:0
> >> A free:1198 slab_reclaimable:1952 slab_unreclaimable:2594
> >> A mapped:10152 shmem:56 pagetables:742 bounce:0
> >> DMA free:2052kB min:84kB low:104kB high:124kB active_anon:940kB inactive_anon:3876kB active_file:212kB inactive_file:8224kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15804kB mlocked:0kB dirty:3448kB writeback:752kB mapped:80kB shmem:0kB slab_reclaimable:160kB slab_unreclaimable:124kB kernel_stack:40kB pagetables:48kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:20096 all_unreclaimable? yes
> >> lowmem_reserve[]: 0 492 492
> >> Normal free:2740kB min:2792kB low:3488kB high:4188kB active_anon:138604kB inactive_anon:161964kB active_file:54092kB inactive_file:103312kB unevictable:0kB isolated(anon):4kB isolated(file):260kB present:503848kB mlocked:0kB dirty:15704kB writeback:21948kB mapped:40528kB shmem:224kB slab_reclaimable:7648kB slab_unreclaimable:10252kB kernel_stack:1632kB pagetables:2920kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:73056 all_unreclaimable? no
> >> lowmem_reserve[]: 0 0 0
> >> DMA: 513*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 2052kB
> >> Normal: 685*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 2740kB
> >> 56122 total pagecache pages
> >> 14542 pages in swap cache
> >> Swap cache stats: add 36404, delete 21862, find 8669/10118
> >> Free swap A = 671696kB
> >> Total swap = 755048kB
> >> 131034 pages RAM
> >> 3214 pages reserved
> >> 94233 pages shared
> >> 80751 pages non-shared
> >> Out of memory: kill process 3462 (kdeinit4) score 95144 or a child
> >
> > shmem=56 is ignorable, and
> > active_file+inactive_file=13576+27884=41460 < 56122 total pagecache pages.
> >
> > Where are the 14606 file pages gone?
> 
> swapcache?

Ah exactly!

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
