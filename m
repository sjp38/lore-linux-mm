Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B21D26B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 05:08:38 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id yr2so10751132wjc.4
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 02:08:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q66si10564059wma.126.2017.01.16.02.08.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Jan 2017 02:08:37 -0800 (PST)
Subject: Re: [PATCH] mm/slub: Add a dump_stack() to the unexpected GFP check
References: <20170116091643.15260-1-bp@alien8.de>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <8d76806c-1413-a412-253a-896394c09d5a@suse.cz>
Date: Mon, 16 Jan 2017 11:08:36 +0100
MIME-Version: 1.0
In-Reply-To: <20170116091643.15260-1-bp@alien8.de>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, Michal Hocko <mhocko@kernel.org>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 01/16/2017 10:16 AM, Borislav Petkov wrote:
> From: Borislav Petkov <bp@suse.de>
> 
> We wanna know who's doing such a thing. Like slab.c does that.
> 
> Signed-off-by: Borislav Petkov <bp@suse.de>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

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
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
