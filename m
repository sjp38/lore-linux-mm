Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2A0486B039F
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 07:30:28 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id r71so28064052wrb.17
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 04:30:28 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f5si24118258wrf.78.2017.04.04.04.30.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Apr 2017 04:30:26 -0700 (PDT)
Date: Tue, 4 Apr 2017 13:30:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Add additional consistency check
Message-ID: <20170404113022.GC15490@dhcp22.suse.cz>
References: <20170331164028.GA118828@beast>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170331164028.GA118828@beast>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 31-03-17 09:40:28, Kees Cook wrote:
> As found in PaX, this adds a cheap check on heap consistency, just to
> notice if things have gotten corrupted in the page lookup.
>
> Signed-off-by: Kees Cook <keescook@chromium.org>

NAK without a proper changelog. Seriously, we do not blindly apply
changes from other projects without a deep understanding of all
consequences.

> ---
>  mm/slab.h | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/slab.h b/mm/slab.h
> index 65e7c3fcac72..64447640b70c 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -384,6 +384,7 @@ static inline struct kmem_cache *cache_from_obj(struct kmem_cache *s, void *x)
>  		return s;
>  
>  	page = virt_to_head_page(x);
> +	BUG_ON(!PageSlab(page));
>  	cachep = page->slab_cache;
>  	if (slab_equal_or_root(cachep, s))
>  		return cachep;
> -- 
> 2.7.4
> 
> 
> -- 
> Kees Cook
> Pixel Security
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
