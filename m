Date: Mon, 14 May 2007 13:25:02 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/5] make slab gfp fair
In-Reply-To: <1179172994.2942.49.camel@lappy>
Message-ID: <Pine.LNX.4.64.0705141324340.12479@schroedinger.engr.sgi.com>
References: <20070514131904.440041502@chello.nl>
 <Pine.LNX.4.64.0705140852150.10442@schroedinger.engr.sgi.com>
 <20070514161224.GC11115@waste.org>  <Pine.LNX.4.64.0705140927470.10801@schroedinger.engr.sgi.com>
  <1179164453.2942.26.camel@lappy>  <Pine.LNX.4.64.0705141051170.11251@schroedinger.engr.sgi.com>
  <1179170912.2942.37.camel@lappy>  <Pine.LNX.4.64.0705141253130.12045@schroedinger.engr.sgi.com>
 <1179172994.2942.49.camel@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Mon, 14 May 2007, Peter Zijlstra wrote:

> > > The thing is; I'm not needing any speed, as long as the machine stay
> > > alive I'm good. However others are planing to build a full reserve based
> > > allocator to properly fix the places that now use __GFP_NOFAIL and
> > > situation such as in add_to_swap().
> > 
> > Well I have version of SLUB here that allows you do redirect the alloc 
> > calls at will. Adds a kmem_cache_ops structure and in the kmem_cache_ops 
> > structure you can redirect allocation and freeing of slabs (not objects!) 
> > at will. Would that help?
> 
> I'm not sure; I need kmalloc as well.

We could add a kmalloc_ops structuret to allow redirects?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
