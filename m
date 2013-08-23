Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 5007A6B0032
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 02:49:28 -0400 (EDT)
Date: Fri, 23 Aug 2013 15:49:39 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 04/16] slab: remove nodeid in struct slab
Message-ID: <20130823064938.GF22605@lge.com>
References: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1377161065-30552-5-git-send-email-iamjoonsoo.kim@lge.com>
 <00000140a7277e81-d259fd75-0dcb-4bef-9e32-d615800201a6-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00000140a7277e81-d259fd75-0dcb-4bef-9e32-d615800201a6-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Aug 22, 2013 at 05:51:58PM +0000, Christoph Lameter wrote:
> On Thu, 22 Aug 2013, Joonsoo Kim wrote:
> 
> > @@ -1099,8 +1098,7 @@ static void drain_alien_cache(struct kmem_cache *cachep,
> >
> >  static inline int cache_free_alien(struct kmem_cache *cachep, void *objp)
> >  {
> > -	struct slab *slabp = virt_to_slab(objp);
> > -	int nodeid = slabp->nodeid;
> > +	int nodeid = page_to_nid(virt_to_page(objp));
> >  	struct kmem_cache_node *n;
> >  	struct array_cache *alien = NULL;
> >  	int node;
> 
> virt_to_page is a relatively expensive operation. How does this affect
> performance?

Previous code, that is virt_to_slab(), already do virt_to_page().
So this doesn't matter at all.

Thanks.

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
