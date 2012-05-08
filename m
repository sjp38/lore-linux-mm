Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id EE6516B00ED
	for <linux-mm@kvack.org>; Tue,  8 May 2012 10:13:11 -0400 (EDT)
Date: Tue, 8 May 2012 09:13:09 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: fix incorrect return type of get_any_partial()
In-Reply-To: <alpine.LFD.2.02.1205080831580.4372@tux.localdomain>
Message-ID: <alpine.DEB.2.00.1205080912590.25669@router.home>
References: <1327651943-28225-1-git-send-email-js1304@gmail.com> <alpine.LFD.2.02.1205080831580.4372@tux.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 8 May 2012, Pekka Enberg wrote:

> On Fri, 27 Jan 2012, Joonsoo Kim wrote:
>
> > Commit 497b66f2ecc97844493e6a147fd5a7e73f73f408 ('slub: return object pointer
> > from get_partial() / new_slab().') changed return type of some functions.
> > This updates missing part.
> >
> > Signed-off-by: Joonsoo Kim <js1304@gmail.com>
> >
> > diff --git a/mm/slub.c b/mm/slub.c
> > index ffe13fd..18bf13e 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -1579,7 +1579,7 @@ static void *get_partial_node(struct kmem_cache *s,
> >  /*
> >   * Get a page from somewhere. Search in increasing NUMA distances.
> >   */
> > -static struct page *get_any_partial(struct kmem_cache *s, gfp_t flags,
> > +static void *get_any_partial(struct kmem_cache *s, gfp_t flags,
> >  		struct kmem_cache_cpu *c)
> >  {
> >  #ifdef CONFIG_NUMA
> > --
> > 1.7.0.4
>
> Applied, thanks!

Could we also fix the comment at the same time?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
