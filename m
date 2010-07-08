Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 30BF56006F5
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 10:05:36 -0400 (EDT)
Date: Thu, 8 Jul 2010 09:04:18 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH v2 2/2] vmscan: shrink_slab() require number of lru_pages,
 not page order
In-Reply-To: <20100708163934.CD37.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1007080901460.9707@router.home>
References: <20100708163401.CD34.A69D9226@jp.fujitsu.com> <20100708163934.CD37.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Thu, 8 Jul 2010, KOSAKI Motohiro wrote:

> Fix simple argument error. Usually 'order' is very small value than
> lru_pages. then it can makes unnecessary icache dropping.

AFAICT this is not argument error but someone changed the naming of the
parameter. The "lru_pages" parameter is really a division factor affecting
the number of pages scanned. This patch increases this division factor
significantly and therefore reduces the number of items scanned during
zone_reclaim.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
