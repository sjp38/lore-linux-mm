Date: Fri, 4 May 2007 09:36:16 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 08/40] mm: kmem_cache_objsize
In-Reply-To: <20070504103157.215424767@chello.nl>
Message-ID: <Pine.LNX.4.64.0705040932200.22033@schroedinger.engr.sgi.com>
References: <20070504102651.923946304@chello.nl> <20070504103157.215424767@chello.nl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, James Bottomley <James.Bottomley@SteelEye.com>, Mike Christie <michaelc@cs.wisc.edu>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Fri, 4 May 2007, Peter Zijlstra wrote:

> Expost buffer_size in order to allow fair estimates on the actual space 
> used/needed.

If its just an estimate that you are after then I think ksize is 
sufficient.

The buffer size does not include the other per slab overhead that SLAB 
needs nor the alignment overhead or the padding. For SLUB you'd be more 
lucky but there it does not include the per slab padding that exist.

Need to check how this is going to be used. It is difficult to estimate 
slab use because this depends on the availability of object slots in 
partial slabs.

I could add a function that tells you how many object you could allocate 
from a slab without the page allocator becoming involved? It would count 
the object slots available on the partial slabs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
