Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1DFB99000BD
	for <linux-mm@kvack.org>; Thu, 22 Sep 2011 07:21:48 -0400 (EDT)
Date: Thu, 22 Sep 2011 12:21:37 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] mm: compaction: staticize compact_zone_order
Message-ID: <20110922112137.GB4213@csn.ul.ie>
References: <20110921085843.GA16233@july>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110921085843.GA16233@july>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kyungmin Park <kmpark@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Sep 21, 2011 at 05:58:43PM +0900, Kyungmin Park wrote:
> From: Kyungmin Park <kyungmin.park@samsung.com>
> 
> There's no user to use compact_zone_order. So staticize this function.
> 
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>

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
