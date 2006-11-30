Subject: Re: [RFC][PATCH 5/6] slab: kmem_cache_objs_to_pages()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0611301053340.23820@schroedinger.engr.sgi.com>
References: <20061130101451.495412000@chello.nl> >
	 <20061130101922.175620000@chello.nl> >
	  <Pine.LNX.4.64.0611301053340.23820@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 30 Nov 2006 19:55:17 +0100
Message-Id: <1164912917.6588.155.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: netdev@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Thu, 2006-11-30 at 10:55 -0800, Christoph Lameter wrote:
> On Thu, 30 Nov 2006, Peter Zijlstra wrote:
> 
> > +unsigned int kmem_cache_objs_to_pages(struct kmem_cache *cachep, int nr)
> > +{
> > +	return ((nr + cachep->num - 1) / cachep->num) << cachep->gfporder;
> 
> cachep->num refers to the number of objects in a slab of gfporder.

Ah, my bad, thanks!

> thus
> 
> return (nr + cachep->num - 1) / cachep->num;
> 
> But then this is very optimistic estimate that assumes a single node and 
> no free objects in between.

Right, perhaps my bad in wording the intent; the needed information is
how many more pages would I need to grow the slab with in order to store
so many new object.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
