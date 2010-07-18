Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D978A6007F3
	for <linux-mm@kvack.org>; Sun, 18 Jul 2010 10:13:21 -0400 (EDT)
Received: by pvc30 with SMTP id 30so1657361pvc.14
        for <linux-mm@kvack.org>; Sun, 18 Jul 2010 07:13:20 -0700 (PDT)
Date: Sun, 18 Jul 2010 23:13:10 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] Tight check of pfn_valid on sparsemem - v2
Message-ID: <20100718141240.GA30402@barrios-desktop>
References: <1279448311-29788-1-git-send-email-minchan.kim@gmail.com>
 <AANLkTilQf-43GMAIDa-MKmcB2afdVgkERMg0b5mhIbhE@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTilQf-43GMAIDa-MKmcB2afdVgkERMg0b5mhIbhE@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Kyungmin Park <kmpark@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Russell King <linux@arm.linux.org.uk>, Kukjin Kim <kgene.kim@samsung.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>
List-ID: <linux-mm.kvack.org>

Hi Kyoungmin, 

On Sun, Jul 18, 2010 at 08:53:25PM +0900, Kyungmin Park wrote:
> Hi Minchan,
> 
> Please see the OneDRAM spec. it's OneDRAM memory usage.
> Actually memory size is 80MiB + 16MiB at AP side and it's used 80MiB
> for dedicated AP.
> The shared 16MiB used between AP and CP. So we also use the 16MiB.

It's not only s5pv210 but general problem of memmap hole 
on ARM's sparsemem. 

It doesn't matter with 16M or 80M. 
The thing is that section size is greater than physical memory's groups.

Current sparsemen aren't designed to have memmap hole but ARM makes holes
to save memory space. So we should solve it by not SECTION_SIZE but more 
fundamental solution.

I think this patch suggests it.
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
