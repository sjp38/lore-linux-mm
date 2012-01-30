Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id E709A6B004D
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 05:47:21 -0500 (EST)
Date: Mon, 30 Jan 2012 10:47:18 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH v3 -mm 3/3] mm: only defer compaction for failed order
 and higher
Message-ID: <20120130104718.GC25268@csn.ul.ie>
References: <20120126145450.2d3d2f4c@cuia.bos.redhat.com>
 <20120126150102.30b75cfe@cuia.bos.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120126150102.30b75cfe@cuia.bos.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Thu, Jan 26, 2012 at 03:01:02PM -0500, Rik van Riel wrote:
> Currently a failed order-9 (transparent hugepage) compaction can
> lead to memory compaction being temporarily disabled for a memory
> zone.  Even if we only need compaction for an order 2 allocation,
> eg. for jumbo frames networking.
> 
> The fix is relatively straightforward: keep track of the highest
> order at which compaction is succeeding, and only defer compaction
> for orders at which compaction is failing.
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
