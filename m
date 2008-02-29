Message-ID: <47C7B826.4090603@cs.helsinki.fi>
Date: Fri, 29 Feb 2008 09:45:42 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch 08/10] slub: Remove BUG_ON() from ksize and omit checks
 for !SLUB_DEBUG
References: <20080229043401.900481416@sgi.com> <20080229043553.076119937@sgi.com>
In-Reply-To: <20080229043553.076119937@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> The BUG_ONs are useless since the pointer derefs will lead to
> NULL deref errors anyways. Some of the checks are not necessary
> if no debugging is possible.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

> +#ifdef CONFIG_SLUB_DEBUG
>  	/*
>  	 * Debugging requires use of the padding between object
>  	 * and whatever may come after it.
> @@ -2634,7 +2632,7 @@ size_t ksize(const void *object)
>  	 */
>  	if (s->flags & (SLAB_DESTROY_BY_RCU | SLAB_STORE_USER))
>  		return s->inuse;
> -
> +#endif

Why are you wrapping the SLAB_DESTORY_BY_RCU case with CONFIG_SLUB_DEBUG 
too?

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
