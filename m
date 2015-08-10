Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id F16246B0253
	for <linux-mm@kvack.org>; Sun,  9 Aug 2015 20:34:59 -0400 (EDT)
Received: by pabyb7 with SMTP id yb7so93640188pab.0
        for <linux-mm@kvack.org>; Sun, 09 Aug 2015 17:34:59 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id t9si11524596pas.186.2015.08.09.17.34.57
        for <linux-mm@kvack.org>;
        Sun, 09 Aug 2015 17:34:59 -0700 (PDT)
Date: Mon, 10 Aug 2015 09:40:22 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2] mm/slub: don't wait for high-order page allocation
Message-ID: <20150810004022.GC26074@js1304-P5Q-DELUXE>
References: <1438913403-3682-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20150807150501.GJ30785@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150807150501.GJ30785@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Shaohua Li <shli@fb.com>, Vlastimil Babka <vbabka@suse.cz>, Eric Dumazet <edumazet@google.com>

On Fri, Aug 07, 2015 at 05:05:01PM +0200, Michal Hocko wrote:
> On Fri 07-08-15 11:10:03, Joonsoo Kim wrote:
> [...]
> > diff --git a/mm/slub.c b/mm/slub.c
> > index 257283f..52b9025 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -1364,6 +1364,8 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
> >  	 * so we fall-back to the minimum order allocation.
> >  	 */
> >  	alloc_gfp = (flags | __GFP_NOWARN | __GFP_NORETRY) & ~__GFP_NOFAIL;
> > +	if ((alloc_gfp & __GFP_WAIT) && oo_order(oo) > oo_order(s->min))
> > +		alloc_gfp = (alloc_gfp | __GFP_NOMEMALLOC) & ~__GFP_WAIT;
> 
> Wouldn't it be preferable to "fix" the __GFP_WAIT behavior than spilling
> __GFP_NOMEMALLOC around the kernel? GFP flags are getting harder and
> harder to use right and that is a signal we should thing about it and
> unclutter the current state.

Maybe, it is preferable. Could you try that?

Anyway, it is separate issue so I don't want pending this patch until
that change.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
