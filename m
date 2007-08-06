From: Daniel Phillips <phillips@phunq.net>
Subject: Re: [PATCH 03/10] mm: tag reseve pages
Date: Mon, 6 Aug 2007 11:13:42 -0700
References: <20070806102922.907530000@chello.nl> <20070806103658.356795000@chello.nl> <Pine.LNX.4.64.0708061111390.25069@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0708061111390.25069@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200708061113.42578.phillips@phunq.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

On Monday 06 August 2007 11:11, Christoph Lameter wrote:
> On Mon, 6 Aug 2007, Peter Zijlstra wrote:
> > ===================================================================
> > --- linux-2.6-2.orig/include/linux/mm_types.h
> > +++ linux-2.6-2/include/linux/mm_types.h
> > @@ -60,6 +60,7 @@ struct page {
> >  	union {
> >  		pgoff_t index;		/* Our offset within mapping. */
> >  		void *freelist;		/* SLUB: freelist req. slab lock */
> > +		int reserve;		/* page_alloc: page is a reserve page */
>
> Extending page struct ???

See my comment above, I do not think this is necessary.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
