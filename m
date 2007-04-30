Date: Mon, 30 Apr 2007 12:02:09 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 3/4] Use SLAB_ACCOUNT_RECLAIM to determine when
 __GFP_RECLAIMABLE should be used
In-Reply-To: <20070430185624.7142.5198.sendpatchset@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0704301201110.7258@schroedinger.engr.sgi.com>
References: <20070430185524.7142.56162.sendpatchset@skynet.skynet.ie>
 <20070430185624.7142.5198.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 30 Apr 2007, Mel Gorman wrote:

 > A number of slab caches are reclaimable and some of their allocation
> callsites were updated to use the __GFP_RECLAIMABLE flag. However, slabs
> that are reclaimable specify the SLAB_ACCOUNT_RECLAIM flag at creation time
> and this information is available at the time of page allocation.

> This patch uses the SLAB_ACCOUNT_RECLAIM flag in the SLAB and SLUB
> allocators to determine if __GFP_RECLAIMABLE should be used when allocating
> pages. The SLOB allocator is not updated as it is unlikely to be used on
> a system where grouping pages by mobility is worthwhile. The callsites
> for reclaimable cache allocations  no longer specify __GFP_RECLAIMABLE
> as the information is redundant. This can be considered as fix to
> group-short-lived-and-reclaimable-kernel-allocations.patch.

Acked-by: Christoph Lameter <clameter@sgi.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
