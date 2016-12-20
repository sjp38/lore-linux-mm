Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 261BD6B0325
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 09:35:57 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id s63so25177485wms.7
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 06:35:57 -0800 (PST)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id l192si19225482wmb.49.2016.12.20.06.35.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 06:35:55 -0800 (PST)
Received: by mail-wm0-f66.google.com with SMTP id g23so24745902wme.1
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 06:35:55 -0800 (PST)
Date: Tue, 20 Dec 2016 15:35:54 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/vmalloc.c: use rb_entry_safe
Message-ID: <20161220143554.GJ3769@dhcp22.suse.cz>
References: <1e433cd03b01a3e89a22de5aa160b3442ff0cf16.1482222608.git.geliangtang@gmail.com>
 <81bb9820e5b9e4a1c596b3e76f88abf8c4a76cb0.1482221947.git.geliangtang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <81bb9820e5b9e4a1c596b3e76f88abf8c4a76cb0.1482221947.git.geliangtang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geliang Tang <geliangtang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, zijun_hu <zijun_hu@htc.com>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Chris Wilson <chris@chris-wilson.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 20-12-16 21:57:43, Geliang Tang wrote:
> Use rb_entry_safe() instead of open-coding it.
> 
> Signed-off-by: Geliang Tang <geliangtang@gmail.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/vmalloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index a558438..b9999fc 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -2309,7 +2309,7 @@ EXPORT_SYMBOL_GPL(free_vm_area);
>  #ifdef CONFIG_SMP
>  static struct vmap_area *node_to_va(struct rb_node *n)
>  {
> -	return n ? rb_entry(n, struct vmap_area, rb_node) : NULL;
> +	return rb_entry_safe(n, struct vmap_area, rb_node);
>  }
>  
>  /**
> -- 
> 2.9.3
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
