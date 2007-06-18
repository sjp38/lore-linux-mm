Date: Mon, 18 Jun 2007 10:24:45 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/7] Memory Compaction v2
In-Reply-To: <20070618092821.7790.52015.sendpatchset@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0706181022530.4751@schroedinger.engr.sgi.com>
References: <20070618092821.7790.52015.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Mon, 18 Jun 2007, Mel Gorman wrote:

> The patchset implements memory compaction for the page allocator reducing
> external fragmentation so that free memory exists as fewer, but larger
> contiguous blocks. Instead of being a full defragmentation solution,
> this focuses exclusively on pages that are movable via the page migration
> mechanism.

We need an additional facility at some point that allows the moving of 
pages that are not on the LRU. Such support seems to be possible
for page table pages and slab pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
