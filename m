Date: Sat, 21 Apr 2007 01:28:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] introduce HIGH_ORDER delineating easily reclaimable
 orders
Message-Id: <20070421012843.f5a814eb.akpm@linux-foundation.org>
In-Reply-To: <cc3c22ba296c3d75cd7bd66747fb08c0@pinky>
References: <exportbomb.1177081388@pinky>
	<cc3c22ba296c3d75cd7bd66747fb08c0@pinky>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Fri, 20 Apr 2007 16:04:36 +0100 Andy Whitcroft <apw@shadowen.org> wrote:

> The memory allocator treats lower order (order <= 3) and higher order
> (order >= 4) allocations in slightly different ways.  As lower orders
> are much more likely to be available and also more likely to be
> simply reclaimed it is deemed reasonable to wait longer for those.
> Lumpy reclaim also changes behaviour at this same boundary, more
> agressivly targetting pages in reclaim at higher order.
> 
> This patch removes all these magical numbers and replaces with
> with a constant HIGH_ORDER.

oh, there we go.

It would have been better to have patched page_alloc.c independently, then
to have used HIGH_ORDER in "lumpy: increase pressure at the end of the inactive
list".

The name HIGH_ORDER is a bit squidgy.  I'm not sure what would be better though.
PAGE_ALLOC_CLUSTER_MAX?

It'd be interesting to turn this into a runtime tunable, perhaps.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
