Date: Mon, 9 Jul 2007 20:44:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: zone movable patches comments
Message-Id: <20070709204425.3dce0eee.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070709110457.GB9305@skynet.ie>
References: <4691E8D1.4030507@yahoo.com.au>
	<20070709110457.GB9305@skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 9 Jul 2007 12:04:57 +0100
mel@skynet.ie (Mel Gorman) wrote:
> It could but it was named this way for a reason. It was more important that
> the administrator get the amount of memory for non-movable allocations
> correct than movable allocations. If the size of ZONE_MOVABLE is wrong,
> the hugepage pool may not be able to grow as large as desired. If the size
> of memory usable of non-movable allocations is wrong, it's worse.
> 
I'd like to vote for kernelcore= rather than movable_mem= :)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
