Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 92FDA6B004A
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 10:21:27 -0400 (EDT)
Date: Tue, 20 Mar 2012 09:21:24 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 2/6] slub: add kmalloc_align()
In-Reply-To: <alpine.DEB.2.00.1203200910030.19333@router.home>
Message-ID: <alpine.DEB.2.00.1203200919520.19333@router.home>
References: <1332238884-6237-1-git-send-email-laijs@cn.fujitsu.com> <1332238884-6237-3-git-send-email-laijs@cn.fujitsu.com> <alpine.DEB.2.00.1203200910030.19333@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 20 Mar 2012, Christoph Lameter wrote:

> > diff --git a/mm/slub.c b/mm/slub.c
> > index 4907563..01cf99d 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -3238,7 +3238,7 @@ static struct kmem_cache *__init create_kmalloc_cache(const char *name,
> >  	 * This function is called with IRQs disabled during early-boot on
> >  	 * single CPU so there's no need to take slub_lock here.
> >  	 */
> > -	if (!kmem_cache_open(s, name, size, ARCH_KMALLOC_MINALIGN,
> > +	if (!kmem_cache_open(s, name, size, ALIGN_OF_LAST_BIT(size),
> >  								flags, NULL))
> >  		goto panic;
>
> Why does the alignment of struct kmem_cache change? I'd rather have a
> __alignof__(struct kmem_cache) here with alignment specified with the
> struct definition.

Ok this aligns the data not the cache . Ok I see what is going on here.
So the kmalloc array now has a higher alignment. That means you can align
up to that limit within the structure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
