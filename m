Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3803B6B025F
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 02:37:34 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id p41so9782882lfi.0
        for <linux-mm@kvack.org>; Sun, 10 Jul 2016 23:37:34 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id d140si13242523wmd.75.2016.07.10.23.37.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Jul 2016 23:37:32 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id i5so199837wmg.2
        for <linux-mm@kvack.org>; Sun, 10 Jul 2016 23:37:32 -0700 (PDT)
Date: Mon, 11 Jul 2016 08:37:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] Add a new field to struct shrinker
Message-ID: <20160711063730.GA5284@dhcp22.suse.cz>
References: <cover.1468051277.git.janani.rvchndrn@gmail.com>
 <85a9712f3853db5d9bc14810b287c23776235f01.1468051281.git.janani.rvchndrn@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <85a9712f3853db5d9bc14810b287c23776235f01.1468051281.git.janani.rvchndrn@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Janani Ravichandran <janani.rvchndrn@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@surriel.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@virtuozzo.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com

On Sat 09-07-16 04:43:31, Janani Ravichandran wrote:
> Struct shrinker does not have a field to uniquely identify the shrinkers
> it represents. It would be helpful to have a new field to hold names of
> shrinkers. This information would be useful while analyzing their
> behavior using tracepoints.

This will however increase the vmlinux size even when no tracing is
enabled. Why cannot we simply print the name of the shrinker callbacks?

> 
> ---
>  include/linux/shrinker.h | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
> index 4fcacd9..431125c 100644
> --- a/include/linux/shrinker.h
> +++ b/include/linux/shrinker.h
> @@ -52,6 +52,7 @@ struct shrinker {
>  	unsigned long (*scan_objects)(struct shrinker *,
>  				      struct shrink_control *sc);
>  
> +	const char *name;
>  	int seeks;	/* seeks to recreate an obj */
>  	long batch;	/* reclaim batch size, 0 = default */
>  	unsigned long flags;
> -- 
> 2.7.0
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
