Date: Mon, 20 Aug 2007 11:06:48 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 5/5] mm/... convert #include "linux/..." to #include
 <linux/...>
In-Reply-To: <1187561983.4200.145.camel@localhost>
Message-ID: <Pine.LNX.4.64.0708201106230.25248@schroedinger.engr.sgi.com>
References: <1187561983.4200.145.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Joe Perches <joe@perches.com>
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org, Eric Dumazet <dada1@cosmosbay.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 19 Aug 2007, Joe Perches wrote:

> diff --git a/mm/slab.c b/mm/slab.c
> index a684778..976aeff 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -334,7 +334,7 @@ static __always_inline int index_of(const size_t size)
>  		return i; \
>  	else \
>  		i++;
> -#include "linux/kmalloc_sizes.h"
> +#include <linux/kmalloc_sizes.h>
>  #undef CACHE
>  		__bad_size();
>  	} else

But I think this was done intentionally to point out that the file 
includes is *not* a regular include file.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
