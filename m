Date: Tue, 8 Apr 2008 13:55:46 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 04/12] slub: Add kmem_cache_order_objects struct
In-Reply-To: <47FA4507.6090409@cs.helsinki.fi>
Message-ID: <Pine.LNX.4.64.0804081351100.31230@schroedinger.engr.sgi.com>
References: <20080404225019.369359572@sgi.com> <20080404225104.311511519@sgi.com>
 <47FA4507.6090409@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Matt Mackall <mpm@selenic.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 7 Apr 2008, Pekka Enberg wrote:

> Hi Christoph,
> 
> Christoph Lameter wrote:
> > @@ -1143,7 +1165,7 @@ static struct page *new_slab(struct kmem
> >  	start = page_address(page);
> >   	if (unlikely(s->flags & SLAB_POISON))
> > -		memset(start, POISON_INUSE, PAGE_SIZE << s->order);
> > +		memset(start, POISON_INUSE, PAGE_SIZE << oo_order(oo));
> 
> This should be compound_order(page) as allocate_slab() can fall back to
> smaller page order.

Ack. I distinctly remember fixing this once before. Sigh.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
