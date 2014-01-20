Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id 8E60A6B0037
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 11:48:03 -0500 (EST)
Received: by mail-we0-f171.google.com with SMTP id w61so7179404wes.16
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 08:48:02 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ci3si1236942wib.74.2014.01.20.08.48.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 20 Jan 2014 08:48:02 -0800 (PST)
Date: Mon, 20 Jan 2014 17:48:01 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH TRIVIAL] memcg: remove unused code from
 kmem_cache_destroy_work_func
Message-ID: <20140120164801.GF2626@dhcp22.suse.cz>
References: <1390209723-11869-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1390209723-11869-1-git-send-email-vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

OK, it seems as a left over from an earlier code reworks but
22933152934f3 doesn't seem to contain any code following that if-else
so maybe review driven changes.

On Mon 20-01-14 13:22:03, Vladimir Davydov wrote:
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c |    6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 7f1a356..7f1511d 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3311,11 +3311,9 @@ static void kmem_cache_destroy_work_func(struct work_struct *w)
>  	 * So if we aren't down to zero, we'll just schedule a worker and try
>  	 * again
>  	 */
> -	if (atomic_read(&cachep->memcg_params->nr_pages) != 0) {
> +	if (atomic_read(&cachep->memcg_params->nr_pages) != 0)
>  		kmem_cache_shrink(cachep);
> -		if (atomic_read(&cachep->memcg_params->nr_pages) == 0)
> -			return;
> -	} else
> +	else
>  		kmem_cache_destroy(cachep);
>  }
>  
> -- 
> 1.7.10.4
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
