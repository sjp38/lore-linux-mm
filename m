Date: Wed, 16 May 2007 16:11:39 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/5] Mark bio_alloc() allocations correctly
In-Reply-To: <20070516230130.10314.48679.sendpatchset@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0705161611250.12119@schroedinger.engr.sgi.com>
References: <20070516230110.10314.85884.sendpatchset@skynet.skynet.ie>
 <20070516230130.10314.48679.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 17 May 2007, Mel Gorman wrote:

> 
> bio_alloc() currently uses __GFP_MOVABLE which is plain wrong. Objects are
> allocated with that gfp mask via mempool. The slab that is ultimatly used
> is not reclaimable or movable.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Acked-by: Andy Whitcroft <apw@shadowen.org>

Acked-by: Christoph Lameter <clameter@sgi.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
