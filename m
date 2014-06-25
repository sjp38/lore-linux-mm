Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id D9D4F6B0031
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 02:55:23 -0400 (EDT)
Received: by mail-we0-f179.google.com with SMTP id w62so1427891wes.24
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 23:55:23 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n9si5136457wiz.23.2014.06.24.23.55.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 24 Jun 2014 23:55:22 -0700 (PDT)
Date: Wed, 25 Jun 2014 08:55:20 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -mm 2/3] page-cgroup: get rid of NR_PCG_FLAGS
Message-ID: <20140625065520.GB10223@dhcp22.suse.cz>
References: <9f5abf8dcb07fe5462f12f81867f199c22e883d3.1403626729.git.vdavydov@parallels.com>
 <26252c1699103f7efe51b224dd61bdb74e31f255.1403626729.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <26252c1699103f7efe51b224dd61bdb74e31f255.1403626729.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 24-06-14 20:33:05, Vladimir Davydov wrote:
> It's not used anywhere today, so let's remove it.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  include/linux/page_cgroup.h |    6 ------
>  kernel/bounds.c             |    2 --
>  2 files changed, 8 deletions(-)
> 
> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> index 23863edb95ff..fb60e4a466c0 100644
> --- a/include/linux/page_cgroup.h
> +++ b/include/linux/page_cgroup.h
> @@ -6,12 +6,8 @@ enum {
>  	PCG_USED,	/* This page is charged to a memcg */
>  	PCG_MEM,	/* This page holds a memory charge */
>  	PCG_MEMSW,	/* This page holds a memory+swap charge */
> -	__NR_PCG_FLAGS,
>  };
>  
> -#ifndef __GENERATING_BOUNDS_H
> -#include <generated/bounds.h>
> -
>  struct pglist_data;
>  
>  #ifdef CONFIG_MEMCG
> @@ -107,6 +103,4 @@ static inline void swap_cgroup_swapoff(int type)
>  
>  #endif /* CONFIG_MEMCG_SWAP */
>  
> -#endif /* !__GENERATING_BOUNDS_H */
> -
>  #endif /* __LINUX_PAGE_CGROUP_H */
> diff --git a/kernel/bounds.c b/kernel/bounds.c
> index 9fd4246b04b8..e1d1d1952bfa 100644
> --- a/kernel/bounds.c
> +++ b/kernel/bounds.c
> @@ -9,7 +9,6 @@
>  #include <linux/page-flags.h>
>  #include <linux/mmzone.h>
>  #include <linux/kbuild.h>
> -#include <linux/page_cgroup.h>
>  #include <linux/log2.h>
>  #include <linux/spinlock_types.h>
>  
> @@ -18,7 +17,6 @@ void foo(void)
>  	/* The enum constants to put into include/generated/bounds.h */
>  	DEFINE(NR_PAGEFLAGS, __NR_PAGEFLAGS);
>  	DEFINE(MAX_NR_ZONES, __MAX_NR_ZONES);
> -	DEFINE(NR_PCG_FLAGS, __NR_PCG_FLAGS);
>  #ifdef CONFIG_SMP
>  	DEFINE(NR_CPUS_BITS, ilog2(CONFIG_NR_CPUS));
>  #endif
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
