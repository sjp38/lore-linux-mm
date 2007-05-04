Date: Fri, 4 May 2007 12:58:27 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 08/40] mm: kmem_cache_objsize
In-Reply-To: <463B812D.5090009@cs.helsinki.fi>
Message-ID: <Pine.LNX.4.64.0705041256210.25267@schroedinger.engr.sgi.com>
References: <20070504102651.923946304@chello.nl>  <20070504103157.215424767@chello.nl>
  <Pine.LNX.4.64.0705040932200.22033@schroedinger.engr.sgi.com>
 <1178301545.24217.56.camel@twins>  <Pine.LNX.4.64.0705041104110.23539@schroedinger.engr.sgi.com>
 <1178302904.2767.6.camel@lappy> <Pine.LNX.4.64.0705041128270.24283@schroedinger.engr.sgi.com>
 <463B7E5C.8030201@cs.helsinki.fi> <Pine.LNX.4.64.0705041142350.24625@schroedinger.engr.sgi.com>
 <463B812D.5090009@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, James Bottomley <James.Bottomley@SteelEye.com>, Mike Christie <michaelc@cs.wisc.edu>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, 4 May 2007, Pekka Enberg wrote:

> Christoph Lameter wrote:
> > SLAB can calculate exactly how many pages are needed. The per cpu and per
> > node stuff is setup at boot and does not change. We are talking about the
> > worst case scenario here. True in case of an off slab
> > we have additional overhead that would also have to go into worst case
> > scenario.
> 
> Fair enough. But there's no way it can take into account any slab management
> structures it needs to allocate. The slab simply doesn't know how many pages
> are needed to _allocate n amount of objects_.

In the worst case we will need need nr_objects / nr_object_per_slab off slab management 
structures. There is one off slab management object per allocated slab.
 
> Peter is interested in a _rough estimate_ so I don't see the point of adding
> that kind of logic in the slab. It's an API that simply cannot satisfy all its
> callers which is why I suggested exposing buffer size in the first place (the
> slab certainly knows how many bytes it needs for one object).

But the slab size is not useful to the caller since the caller does not 
know about off slab structures etc. It is only the SLAB that can 
calculate the worst case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
