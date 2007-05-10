Subject: Re: [patch] slob: implement RCU freeing
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <4642D751.4060103@yahoo.com.au>
References: <Pine.LNX.4.64.0705081746500.16914@schroedinger.engr.sgi.com>
	 <20070509012725.GZ11115@waste.org>
	 <Pine.LNX.4.64.0705081828300.17376@schroedinger.engr.sgi.com>
	 <20070508.185141.85412154.davem@davemloft.net>
	 <46412BB5.1060605@yahoo.com.au>
	 <20070509174238.b4152887.akpm@linux-foundation.org>
	 <46426EA1.4030408@yahoo.com.au> <20070510022707.GO11115@waste.org>
	 <4642C6A2.1090809@yahoo.com.au> <1178785328.6810.19.camel@twins>
	 <4642D751.4060103@yahoo.com.au>
Content-Type: text/plain
Date: Thu, 10 May 2007 10:29:25 +0200
Message-Id: <1178785765.6810.24.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-05-10 at 18:26 +1000, Nick Piggin wrote:

> Indeed, how's this?
> 
> plain text document attachment (slob-add-rcu-fix.patch)
> Index: linux-2.6/mm/slob.c
> ===================================================================
> --- linux-2.6.orig/mm/slob.c
> +++ linux-2.6/mm/slob.c
> @@ -296,7 +296,7 @@ struct kmem_cache *kmem_cache_create(con
>  		c->name = name;
>  		c->size = size;
>  		if (flags & SLAB_DESTROY_BY_RCU) {
> -			BUG_ON(c->dtor);
> +			BUG_ON(dtor);
>  			/* leave room for rcu footer at the end of object */
>  			c->size += sizeof(struct slob_rcu);
>  		}

works for me :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
