Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 699AF6B02AD
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 11:01:39 -0400 (EDT)
Date: Thu, 5 Aug 2010 16:02:32 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/7] vmscan: raise the bar to PAGEOUT_IO_SYNC stalls
Message-ID: <20100805150232.GE25688@csn.ul.ie>
References: <20100805150624.31B7.A69D9226@jp.fujitsu.com> <20100805151125.31BA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100805151125.31BA.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 05, 2010 at 03:12:22PM +0900, KOSAKI Motohiro wrote:
> From: Wu Fengguang <fengguang.wu@intel.com>
> 
> Fix "system goes unresponsive under memory pressure and lots of
> dirty/writeback pages" bug.
> 
> 	http://lkml.org/lkml/2010/4/4/86
> 
> In the above thread, Andreas Mohr described that
> 
> 	Invoking any command locked up for minutes (note that I'm
> 	talking about attempted additional I/O to the _other_,
> 	_unaffected_ main system HDD - such as loading some shell
> 	binaries -, NOT the external SSD18M!!).
> 
> This happens when the two conditions are both meet:
> - under memory pressure
> - writing heavily to a slow device
> 
> <SNIP>

Other than an unnecessary whitespace removal at the end of the patch, I see
no problem with letting this patch stand on it's own as we are
reasonably sure this patch fixes a problem on its own. Patches 2-7 might
further improve the situation but can be considered as a new series.

This patch (as well as most of the series) will reject against current mmotm
because of other reclaim-related patches already in there. The resolutions
are not too hard but bear it in mind.

> <SNIP>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
