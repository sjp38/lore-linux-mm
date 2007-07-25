Date: Tue, 24 Jul 2007 23:00:11 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: NUMA policy issues with ZONE_MOVABLE
In-Reply-To: <46A6DE75.70803@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0707242256100.4425@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com>
 <46A6D5E1.70407@yahoo.com.au> <Pine.LNX.4.64.0707242200380.4070@schroedinger.engr.sgi.com>
 <46A6DE75.70803@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, ak@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@skynet.ie>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, 25 Jul 2007, Nick Piggin wrote:

> > Highmem is only used on i386 NUMA and works fine on NUMAQ. The current zone
> > types are carefully fitted to existing NUMA systems.
> 
> I don't understand what you mean. Aren't mempolicies also supposed to
> work on NUMAQ too? How about DMA and DMA32 allocations?

Memory policies work on NUMAQ. Please read up on memory policies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
