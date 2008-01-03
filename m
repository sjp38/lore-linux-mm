Date: Thu, 3 Jan 2008 02:03:11 +0100
From: Andrea Arcangeli <andrea@cpushare.com>
Subject: Re: [PATCH 06 of 24] reduce the probability of an OOM livelock
Message-ID: <20080103010311.GJ30939@v2.random>
References: <patchbomb.1187786927@v2.random> <49e2d90eb0d7b1021b1e.1187786933@v2.random> <20070912051730.c9efd406.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070912051730.c9efd406.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 12, 2007 at 05:17:30AM -0700, Andrew Morton wrote:
> I don't get it.  This code changes try_to_free_pages() so that it will only
> bale out when a single scan of the zone at a particular priority reclaimed
> more than swap_cluster_max pages.  Previously we'd include the results of all the
> lower-priority scanning in that comparison too.
> 
> So this patch will make try_to_free_pages() do _more_ scanning than it used
> to, in some situations.  Which seems opposite to what you're trying to do
> here.

It will do more scanning because it will think to be oom sooner!  And
OOM-sooner = less scanning. My objective is to go oom sooner. Not
after zillon of lru passes. Only 1 pass at priority 0 failing is now
enough to declare oom. Previously all previous passes had to fail too.

> A similar situation exists with this change.

Yes.

> Your changelog made no mention of the change to balance_pgdat() and I'm
> struggling a bit to see what it's doing in there.

I thought it better work the same for both.

> In both places, the definition of local variable nr_reclaimed can be moved
> into a more inner scope.  This makes the code easier to follow.  Please
> watch out for cleanup opportunities like that.

Cleaned up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
