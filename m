Date: Sat, 5 May 2007 08:43:31 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 1/3] SLUB: slab_ops instead of constructors / destructors
In-Reply-To: <84144f020705050314s36510c98j70d1ca8e3770f00e@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0705050843230.26574@schroedinger.engr.sgi.com>
References: <20070504221555.642061626@sgi.com>  <20070504221708.363027097@sgi.com>
 <84144f020705050314s36510c98j70d1ca8e3770f00e@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com, Eric Dumazet <dada1@cosmosbay.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Sat, 5 May 2007, Pekka Enberg wrote:

> For consistency with other operations structures, can we make this
> struct kmem_cache_operations or kmem_cache_ops, please?

Ok.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
