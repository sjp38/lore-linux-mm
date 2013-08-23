Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 78DE96B0032
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 02:40:33 -0400 (EDT)
Date: Fri, 23 Aug 2013 15:40:43 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 02/16] slab: change return type of kmem_getpages() to
 struct page
Message-ID: <20130823064043.GE22605@lge.com>
References: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1377161065-30552-3-git-send-email-iamjoonsoo.kim@lge.com>
 <00000140a725706c-27ed3820-ef32-4388-825a-de582055d91d-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00000140a725706c-27ed3820-ef32-4388-825a-de582055d91d-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Aug 22, 2013 at 05:49:43PM +0000, Christoph Lameter wrote:
> On Thu, 22 Aug 2013, Joonsoo Kim wrote:
> 
> > @@ -2042,7 +2042,7 @@ static void slab_destroy_debugcheck(struct kmem_cache *cachep, struct slab *slab
> >   */
> >  static void slab_destroy(struct kmem_cache *cachep, struct slab *slabp)
> >  {
> > -	void *addr = slabp->s_mem - slabp->colouroff;
> > +	struct page *page = virt_to_head_page(slabp->s_mem);
> >
> >  	slab_destroy_debugcheck(cachep, slabp);
> >  	if (unlikely(cachep->flags & SLAB_DESTROY_BY_RCU)) {
> 
> Ok so this removes slab offset management. The use of a struct page
> pointer therefore results in coloring support to be not possible anymore.

No, slab offset management is done by colour_off in struct kmem_cache.
This colouroff in struct slab is just for getting start address of the page
at free time. If we can get start address properly, we can remove it without
any side-effect. This patch implement it.

Thanks.

> 
> I would suggest to have a separate patch for coloring removal before this
> patch. It seems that the support is removed in two different patches now.
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
