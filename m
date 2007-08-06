Date: Mon, 6 Aug 2007 11:43:43 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 03/10] mm: tag reseve pages
In-Reply-To: <p73r6mglaog.fsf@bingen.suse.de>
Message-ID: <Pine.LNX.4.64.0708061143050.3152@schroedinger.engr.sgi.com>
References: <20070806102922.907530000@chello.nl> <20070806103658.356795000@chello.nl>
 <Pine.LNX.4.64.0708061111390.25069@schroedinger.engr.sgi.com>
 <p73r6mglaog.fsf@bingen.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 6 Aug 2007, Andi Kleen wrote:

> > >  		pgoff_t index;		/* Our offset within mapping. */
> > >  		void *freelist;		/* SLUB: freelist req. slab lock */
> > > +		int reserve;		/* page_alloc: page is a reserve page */
> > 
> > Extending page struct ???
> 
> Note it's an union.

Ok. Then under what conditions can we use reserve? Right after alloc?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
