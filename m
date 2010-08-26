Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id DDA1B6B01F1
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 05:03:20 -0400 (EDT)
Date: Thu, 26 Aug 2010 10:03:05 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH v2 1/2] compaction: handle active and inactive fairly
	in too_many_isolated
Message-ID: <20100826090305.GC20944@csn.ul.ie>
References: <1282663879-4130-1-git-send-email-minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1282663879-4130-1-git-send-email-minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, Iram Shahzad <iram.shahzad@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 25, 2010 at 12:31:18AM +0900, Minchan Kim wrote:
> Iram reported compaction's too_many_isolated loops forever.
> (http://www.spinics.net/lists/linux-mm/msg08123.html)
> 
> The meminfo of situation happened was inactive anon is zero.
> That's because the system has no memory pressure until then.
> While all anon pages was in active lru, compaction could select
> active lru as well as inactive lru. That's different things
> with vmscan's isolated. So we has been two too_many_isolated.
> 
> While compaction can isolated pages in both active and inactive,
> current implementation of too_many_isolated only considers inactive.
> It made Iram's problem.
> 
> This patch handles active and inactive with fair.
> That's because we can't expect where from and how many compaction would
> isolated pages.
> 
> This patch changes (nr_isolated > nr_inactive) with
> nr_isolated > (nr_active + nr_inactive) / 2.
> 
> Cc: Iram Shahzad <iram.shahzad@jp.fujitsu.com>
> Acked-by: Mel Gorman <mel@csn.ul.ie>
> Acked-by: Wu Fengguang <fengguang.wu@intel.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

Please send this patch on its own as it looks like it should be merged and
arguably is a stable candidate for 2.6.35. Alternatively, Andrew, can you pick
up just this patch? It seems unrelated to the second patch on COMPACTPAGEFAILED.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
