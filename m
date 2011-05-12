Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 9D94D900001
	for <linux-mm@kvack.org>; Thu, 12 May 2011 16:01:47 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p4CK1kRY019461
	for <linux-mm@kvack.org>; Thu, 12 May 2011 13:01:46 -0700
Received: from pwi6 (pwi6.prod.google.com [10.241.219.6])
	by wpaz29.hot.corp.google.com with ESMTP id p4CK0AI7014885
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 12 May 2011 13:01:44 -0700
Received: by pwi6 with SMTP id 6so1152173pwi.18
        for <linux-mm@kvack.org>; Thu, 12 May 2011 13:01:44 -0700 (PDT)
Date: Thu, 12 May 2011 13:01:42 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Slub cleanup6 2/5] slub: get_map() function to establish map
 of free objects in a slab
In-Reply-To: <alpine.DEB.2.00.1105121140510.27324@router.home>
Message-ID: <alpine.DEB.2.00.1105121301280.2407@chino.kir.corp.google.com>
References: <20110415194811.810587216@linux.com> <20110415194830.839125394@linux.com> <alpine.DEB.2.00.1105111302020.9346@chino.kir.corp.google.com> <alpine.DEB.2.00.1105121140510.27324@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org

On Thu, 12 May 2011, Christoph Lameter wrote:

> Subject: slub: Avoid warning for !CONFIG_SLUB_DEBUG
> 
> Move the #ifdef so that get_map is only defined if CONFIG_SLUB_DEBUG is defined.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Acked-by: David Rientjes <rientjes@google.com>

> 
> ---
>  mm/slub.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2011-05-12 11:38:42.000000000 -0500
> +++ linux-2.6/mm/slub.c	2011-05-12 11:39:40.000000000 -0500
> @@ -326,6 +326,7 @@ static inline int oo_objects(struct kmem
>  	return x.x & OO_MASK;
>  }
> 
> +#ifdef CONFIG_SLUB_DEBUG
>  /*
>   * Determine a map of object in use on a page.
>   *
> @@ -341,7 +342,6 @@ static void get_map(struct kmem_cache *s
>  		set_bit(slab_index(p, s, addr), map);
>  }
> 
> -#ifdef CONFIG_SLUB_DEBUG
>  /*
>   * Debug settings:
>   */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
