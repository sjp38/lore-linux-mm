Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E89376B007B
	for <linux-mm@kvack.org>; Wed,  8 Sep 2010 16:05:53 -0400 (EDT)
Date: Wed, 8 Sep 2010 15:05:47 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/3] mm: page allocator: Drain per-cpu lists after direct
 reclaim allocation fails
In-Reply-To: <20100908163956.C930.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1009081500070.14871@router.home>
References: <1283504926-2120-1-git-send-email-mel@csn.ul.ie> <1283504926-2120-4-git-send-email-mel@csn.ul.ie> <20100908163956.C930.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 8 Sep 2010, KOSAKI Motohiro wrote:

> nit: when slub, get_page_from_freelist() failure is frequently happen
> than slab because slub try to allocate high order page at first.
> So, I guess we have to avoid drain_all_pages() if __GFP_NORETRY is passed.

SLAB also tries to allocate higher order pages for many slabs but not as
high as SLUB (SLAB does not support fallback to order 0). SLAB also always
uses GFP_THISNODE (which include GFP_NORETRY).

Your patch will make SLAB's initial call to the page allocator fail more
frequently and therefore will increase the use of fallback_alloc().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
