Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4BCFC6B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 04:38:49 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id ez4so7401450wjd.2
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 01:38:49 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a63si20944113wrc.293.2017.01.16.01.38.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Jan 2017 01:38:48 -0800 (PST)
Date: Mon, 16 Jan 2017 10:38:47 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/slub: Add a dump_stack() to the unexpected GFP check
Message-ID: <20170116093846.GD13641@dhcp22.suse.cz>
References: <20170116091643.15260-1-bp@alien8.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170116091643.15260-1-bp@alien8.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

[Let's add Andrew]

On Mon 16-01-17 10:16:43, Borislav Petkov wrote:
> From: Borislav Petkov <bp@suse.de>
> 
> We wanna know who's doing such a thing. Like slab.c does that.

Yes this was an omission on my side in 72baeef0c271 ("slab: do not panic
on invalid gfp_mask").
> 
> Signed-off-by: Borislav Petkov <bp@suse.de>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  mm/slub.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index 067598a00849..1b0fa7625d6d 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1623,6 +1623,7 @@ static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
>  		flags &= ~GFP_SLAB_BUG_MASK;
>  		pr_warn("Unexpected gfp: %#x (%pGg). Fixing up to gfp: %#x (%pGg). Fix your code!\n",
>  				invalid_mask, &invalid_mask, flags, &flags);
> +		dump_stack();
>  	}
>  
>  	return allocate_slab(s,
> -- 
> 2.11.0

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
