Date: Tue, 15 May 2007 11:31:12 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 8/8] Mark page cache pages as __GFP_PAGECACHE instead of
 __GFP_MOVABLE
In-Reply-To: <20070515150552.16348.15975.sendpatchset@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0705151130250.31972@schroedinger.engr.sgi.com>
References: <20070515150311.16348.56826.sendpatchset@skynet.skynet.ie>
 <20070515150552.16348.15975.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 15 May 2007, Mel Gorman wrote:

> This patch marks page cache allocations as __GFP_PAGECACHE instead of
> __GFP_MOVABLE. To make code easier to read, a set of three GFP flags are
> added called GFP_PAGECACHE, GFP_NOFS_PAGECACHE and GFP_HIGHUSER_PAGECACHE.

What motivated this patch? Are there any special flags that are needed for 
the pagecache? 

If we have this flag then we could move the functionality from 
__page_cache_alloc (mm/filemap.c) into the page allocator?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
