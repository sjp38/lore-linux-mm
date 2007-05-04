Message-ID: <463B7E5C.8030201@cs.helsinki.fi>
Date: Fri, 04 May 2007 21:41:32 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH 08/40] mm: kmem_cache_objsize
References: <20070504102651.923946304@chello.nl>  <20070504103157.215424767@chello.nl>  <Pine.LNX.4.64.0705040932200.22033@schroedinger.engr.sgi.com>  <1178301545.24217.56.camel@twins>  <Pine.LNX.4.64.0705041104110.23539@schroedinger.engr.sgi.com> <1178302904.2767.6.camel@lappy> <Pine.LNX.4.64.0705041128270.24283@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0705041128270.24283@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, James Bottomley <James.Bottomley@SteelEye.com>, Mike Christie <michaelc@cs.wisc.edu>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> Hmmm... Maybe lets have
> 
> unsigned kmem_estimate_pages(struct kmem_cache *slab_cache, int objects)
> 
> which would calculate the worst case memory scenario for allocation the 
> number of indicated objects?

IIRC this looks more or less what Peter had initially. I don't like the 
API because there's no way for slab (perhaps this is different for slub) 
how many pages you really need due to per-node and per-cpu caches, etc.

It's better that the slab tells you what it actually knows and lets the 
callers figure out what a worst-case upper bound is.

				Pekka


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
