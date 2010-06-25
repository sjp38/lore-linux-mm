Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3DD0A6B01AD
	for <linux-mm@kvack.org>; Fri, 25 Jun 2010 10:08:12 -0400 (EDT)
Date: Fri, 25 Jun 2010 09:07:39 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 1/2] vmscan: shrink_slab() require number of lru_pages,
 not page order
In-Reply-To: <20100625201915.8067.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006250857040.18900@router.home>
References: <20100625201915.8067.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Fri, 25 Jun 2010, KOSAKI Motohiro wrote:

> Fix simple argument error. Usually 'order' is very small value than
> lru_pages. then it can makes unnecessary icache dropping.

This is going to reduce the delta that is added to shrinker->nr
significantly thereby increasing the number of times that shrink_slab() is
called.

What does the "lru_pages" parameter do in shrink_slab()? Looks
like its only role is as a divison factor in a complex calculation of
pages to be scanned.

do_try_to_free_pages passes 0 as "lru_pages" to shrink_slab() when trying
to do cgroup lru scans. Why is that?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
