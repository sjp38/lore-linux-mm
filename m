Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 6DADE6B004D
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 05:36:16 -0500 (EST)
Date: Mon, 30 Jan 2012 10:36:13 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH v3 -mm 1/3] mm: reclaim at order 0 when compaction is
 enabled
Message-ID: <20120130103612.GB25268@csn.ul.ie>
References: <20120126145450.2d3d2f4c@cuia.bos.redhat.com>
 <20120126145914.58619765@cuia.bos.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120126145914.58619765@cuia.bos.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Thu, Jan 26, 2012 at 02:59:14PM -0500, Rik van Riel wrote:
> When built with CONFIG_COMPACTION, kswapd should not try to free
> contiguous pages, because it is not trying hard enough to have
> a real chance at being successful, but still disrupts the LRU
> enough to break other things.
> 
> Do not do higher order page isolation unless we really are in
> lumpy reclaim mode.
> 
> Stop reclaiming pages once we have enough free pages that
> compaction can deal with things, and we hit the normal order 0
> watermarks used by kswapd.
> 
> Also remove a line of code that increments balanced right before
> exiting the function.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
