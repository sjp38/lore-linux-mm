From: Andi Kleen <ak@suse.de>
Subject: Re: NUMA policy issues with ZONE_MOVABLE
Date: Wed, 25 Jul 2007 11:32:54 +0200
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0707242200380.4070@schroedinger.engr.sgi.com> <46A6DE75.70803@yahoo.com.au>
In-Reply-To: <46A6DE75.70803@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200707251132.54572.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@skynet.ie>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wednesday 25 July 2007 07:24:05 Nick Piggin wrote:

> I don't understand what you mean. Aren't mempolicies also supposed to
> work on NUMAQ too? How about DMA and DMA32 allocations?

bind mempolicies only support one zone, always the highest. This means on numaq
only highmem is policied.

DMA/DMA32 is not policied for obvious reasons (they often don't exist on
all nodes) 

> Well I guess you haven't succeeded in getting zones removed, so I think
> we should make mempolicies work better with zones.

Why? That would just complicate everything. In particular it would mean
you would need multiple fallback lists per VMA, which would increase
the memory usage significantly.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
