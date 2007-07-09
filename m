Date: Mon, 9 Jul 2007 10:39:25 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: zone movable patches comments
In-Reply-To: <20070709110457.GB9305@skynet.ie>
Message-ID: <Pine.LNX.4.64.0707091035300.16075@schroedinger.engr.sgi.com>
References: <4691E8D1.4030507@yahoo.com.au> <20070709110457.GB9305@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 9 Jul 2007, Mel Gorman wrote:

> > much overhead if the zone is not populated, but there has been a fair
> > bit of work towards taking out unneeded zones.
> > 
> 
> It could be made configurable as zone_type already has configurable
> zones. However, as it is that would always be set on distro kernels for
> CONFIG_HUGETLB_PAGE, is there any point? It might make sense for embedded
> systems but I've received pushback from Andrew before for trying to introduce
> config options that affect the allocator before.

Well it could be removed when we get memory compaction right? Its only 
useful to guarantee reclaimable memory in a certain region when we only 
have antifrag? The more memory becomes movable the less need for it.

> It could but it was named this way for a reason. It was more important that
> the administrator get the amount of memory for non-movable allocations
> correct than movable allocations. If the size of ZONE_MOVABLE is wrong,
> the hugepage pool may not be able to grow as large as desired. If the size
> of memory usable of non-movable allocations is wrong, it's worse.

Yeah that causes concern. The current situation is that the huge page pool 
grows until fragmentation makes it impossible to get more. If you would 
remove ZONE_MOVABLE then that situation would continue to exist. The 
guarantee is useful as long as we do not have memory 
defragmentation/compaction because then reclaim can guarantee that the 
desired number of higher order pages can be obtained through reclaiming pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
