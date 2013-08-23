Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 326C26B0032
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 02:55:33 -0400 (EDT)
Date: Fri, 23 Aug 2013 15:55:43 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 09/16] slab: use __GFP_COMP flag for allocating slab pages
Message-ID: <20130823065543.GH22605@lge.com>
References: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1377161065-30552-10-git-send-email-iamjoonsoo.kim@lge.com>
 <00000140a72fb556-3269e81c-8829-4c26-a57f-c1bb7e40977b-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00000140a72fb556-3269e81c-8829-4c26-a57f-c1bb7e40977b-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Aug 22, 2013 at 06:00:56PM +0000, Christoph Lameter wrote:
> On Thu, 22 Aug 2013, Joonsoo Kim wrote:
> 
> > If we use 'struct page' of first page as 'struct slab', there is no
> > advantage not to use __GFP_COMP. So use __GFP_COMP flag for all the cases.
> 
> Ok that brings it in line with SLUB and SLOB.

Yes!

> 
> > @@ -2717,17 +2701,8 @@ static void slab_put_obj(struct kmem_cache *cachep, struct slab *slabp,
> >  static void slab_map_pages(struct kmem_cache *cache, struct slab *slab,
> >  			   struct page *page)
> >  {
> > -	int nr_pages;
> > -
> > -	nr_pages = 1;
> > -	if (likely(!PageCompound(page)))
> > -		nr_pages <<= cache->gfporder;
> > -
> > -	do {
> > -		page->slab_cache = cache;
> > -		page->slab_page = slab;
> > -		page++;
> > -	} while (--nr_pages);
> > +	page->slab_cache = cache;
> > +	page->slab_page = slab;
> >  }
> 
> And saves some processing.

Yes!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
