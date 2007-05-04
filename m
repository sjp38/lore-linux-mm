Subject: Re: [PATCH 08/40] mm: kmem_cache_objsize
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0705040932200.22033@schroedinger.engr.sgi.com>
References: <20070504102651.923946304@chello.nl>
	 <20070504103157.215424767@chello.nl>
	 <Pine.LNX.4.64.0705040932200.22033@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 04 May 2007 19:59:05 +0200
Message-Id: <1178301545.24217.56.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, James Bottomley <James.Bottomley@SteelEye.com>, Mike Christie <michaelc@cs.wisc.edu>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-05-04 at 09:36 -0700, Christoph Lameter wrote:
> On Fri, 4 May 2007, Peter Zijlstra wrote:
> 
> > Expost buffer_size in order to allow fair estimates on the actual space 
> > used/needed.
> 
> If its just an estimate that you are after then I think ksize is 
> sufficient.
> 
> The buffer size does not include the other per slab overhead that SLAB 
> needs nor the alignment overhead or the padding. For SLUB you'd be more 
> lucky but there it does not include the per slab padding that exist.
> 
> Need to check how this is going to be used. It is difficult to estimate 
> slab use because this depends on the availability of object slots in 
> partial slabs.
> 
> I could add a function that tells you how many object you could allocate 
> from a slab without the page allocator becoming involved? It would count 
> the object slots available on the partial slabs.

I need to know how many pages to reserve to allocate a given number of
items from a given slab; assuming the partial slabs are empty. That is,
I need a worst case upper bound.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
