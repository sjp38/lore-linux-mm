Date: Tue, 18 Mar 2008 12:00:13 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 7/9] slub: Adjust order boundaries and minimum objects
 per slab.
In-Reply-To: <47E00FEF.10604@cs.helsinki.fi>
Message-ID: <Pine.LNX.4.64.0803181159450.23790@schroedinger.engr.sgi.com>
References: <20080317230516.078358225@sgi.com> <20080317230529.474353536@sgi.com>
 <47E00FEF.10604@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Mel Gorman <mel@csn.ul.ie>, Matt Mackall <mpm@selenic.com>, yanmin_zhang@linux.intel.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 Mar 2008, Pekka Enberg wrote:

> Christoph Lameter wrote:
> > Since there is now no worry anymore about higher order allocs (hopefully).
> > Set the max order to default to PAGE_ALLOC_ORDER_COSTLY (32k) and require
> > slub to use a higher order if a certain object density cannot be reached.
> > 
> > The mininum objects per slab is calculated based on the number of processors
> > that may come online.
> 
> Interesting. Why do we want to make min objects depend on CPU count and not
> amount of memory available on the system?

Yanmin found a performance correlation with processors. He may be able to 
expand on that.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
