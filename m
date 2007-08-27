Date: Mon, 27 Aug 2007 16:51:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 0/6] Per cpu structures for SLUB
Message-Id: <20070827165126.a1a9846b.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0708271144440.4667@schroedinger.engr.sgi.com>
References: <20070823064653.081843729@sgi.com>
	<20070824143848.a1ecb6bc.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0708271144440.4667@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Mon, 27 Aug 2007 11:50:10 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Fri, 24 Aug 2007, Andrew Morton wrote:
> 
> > I'm struggling a bit to understand these numbers.  Bigger is better, I
> > assume?  In what units are these numbers?
> 
> No less is better. These are cycle counts. Hmmm... We discussed these 
> cycle counts so much in the last week that I forgot to mention that.
> 
> > > Page allocator pass through
> > > ---------------------------
> > > There is a significant difference in the columns marked with a * because
> > > of the way that allocations for page sized objects are handled.
> > 
> > OK, but what happened to the third pair of columns (Concurrent Alloc,
> > Kmalloc) for 1024 and 2048-byte allocations?  They seem to have become
> > significantly slower?
> 
> There is a significant performance increase there. That is the main point 
> of the patch.
> 
> > Thanks for running the numbers, but it's still a bit hard to work out
> > whether these changes are an aggregate benefit?
> 
> There is a drawback because of the additional code introduced in the fast 
> path. However, the regular kmalloc case shows improvements throughout. 
> This is in particular of importance for SMP systems. We see an improvement 
> even for 2 processors.

umm, OK.  When you have time, could you please whizz up a clearer
changelog for this one?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
