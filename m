Date: Tue, 15 May 2007 13:04:09 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 8/8] Mark page cache pages as __GFP_PAGECACHE instead of
 __GFP_MOVABLE
In-Reply-To: <20070515195206.GA14028@skynet.ie>
Message-ID: <Pine.LNX.4.64.0705151303170.1712@schroedinger.engr.sgi.com>
References: <20070515150311.16348.56826.sendpatchset@skynet.skynet.ie>
 <20070515150552.16348.15975.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0705151130250.31972@schroedinger.engr.sgi.com>
 <20070515195206.GA14028@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 15 May 2007, Mel Gorman wrote:

> Currently page cache pages are grouped with MOVABLE allocations. This appears
> to work well in practice as page cache pages are usually reclaimable via
> the LRU. However, this is not strictly correct as page cache pages can only
> be cleaned and discarded, not migrated. During readahead, pages may also
> exist on a pool for a period of time instead of on the LRU giving them a
> differnet lifecycle to ordinary movable pages.

Sorry but pagecache pages can be migrated.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
