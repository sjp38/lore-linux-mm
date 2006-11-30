Date: Thu, 30 Nov 2006 10:55:51 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 5/6] slab: kmem_cache_objs_to_pages()
In-Reply-To: <20061130101922.175620000@chello.nl>>
Message-ID: <Pine.LNX.4.64.0611301053340.23820@schroedinger.engr.sgi.com>
References: <20061130101451.495412000@chello.nl>> <20061130101922.175620000@chello.nl>>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: netdev@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Thu, 30 Nov 2006, Peter Zijlstra wrote:

> +unsigned int kmem_cache_objs_to_pages(struct kmem_cache *cachep, int nr)
> +{
> +	return ((nr + cachep->num - 1) / cachep->num) << cachep->gfporder;

cachep->num refers to the number of objects in a slab of gfporder.

thus

return (nr + cachep->num - 1) / cachep->num;

But then this is very optimistic estimate that assumes a single node and 
no free objects in between.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
