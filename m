Date: Tue, 19 Jun 2007 17:58:41 +0100
Subject: Re: [PATCH 0/7] Memory Compaction v2
Message-ID: <20070619165841.GG17109@skynet.ie>
References: <20070618092821.7790.52015.sendpatchset@skynet.skynet.ie> <Pine.LNX.4.64.0706181022530.4751@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706181022530.4751@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On (18/06/07 10:24), Christoph Lameter didst pronounce:
> On Mon, 18 Jun 2007, Mel Gorman wrote:
> 
> > The patchset implements memory compaction for the page allocator reducing
> > external fragmentation so that free memory exists as fewer, but larger
> > contiguous blocks. Instead of being a full defragmentation solution,
> > this focuses exclusively on pages that are movable via the page migration
> > mechanism.
> 
> We need an additional facility at some point that allows the moving of 
> pages that are not on the LRU. Such support seems to be possible
> for page table pages and slab pages.

Agreed. When I put this together first, I felt I would be able to isolate
pages of different types on migratelist but that is not the case as migration
would not be able to tell the difference between a LRU page and a pagetable
page. I'll rename cc->migratelist to cc->migratelist_lru with the view to
potentially adding cc->migratelist_pagetable or cc->migratelist_slab later.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
