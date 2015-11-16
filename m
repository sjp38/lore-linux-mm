Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 567EF6B0254
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 07:43:09 -0500 (EST)
Received: by wmvv187 with SMTP id v187so174266999wmv.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 04:43:09 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id 63si25410953wmx.10.2015.11.16.04.43.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Nov 2015 04:43:08 -0800 (PST)
Received: by wmuu63 with SMTP id u63so25641355wmu.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 04:43:08 -0800 (PST)
Date: Mon, 16 Nov 2015 13:43:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/7] mm/lru: remove unused is_unevictable_lru function
Message-ID: <20151116124307.GE14116@dhcp22.suse.cz>
References: <1447656686-4851-1-git-send-email-baiyaowei@cmss.chinamobile.com>
 <1447656686-4851-6-git-send-email-baiyaowei@cmss.chinamobile.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1447656686-4851-6-git-send-email-baiyaowei@cmss.chinamobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Cc: akpm@linux-foundation.org, bhe@redhat.com, dan.j.williams@intel.com, dave.hansen@linux.intel.com, dave@stgolabs.net, dhowells@redhat.com, dingel@linux.vnet.ibm.com, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, holt@sgi.com, iamjoonsoo.kim@lge.com, joe@perches.com, kuleshovmail@gmail.com, mgorman@suse.de, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, penberg@kernel.org, rientjes@google.com, sasha.levin@oracle.com, tj@kernel.org, tony.luck@intel.com, vbabka@suse.cz, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 16-11-15 14:51:24, Yaowei Bai wrote:
> Since commit a0b8cab3 ("mm: remove lru parameter from __pagevec_lru_add
> and remove parts of pagevec API") there's no user of this function anymore,
> so remove it.
> 
> Signed-off-by: Yaowei Bai <baiyaowei@cmss.chinamobile.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/mmzone.h | 5 -----
>  1 file changed, 5 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index e23a9e7..9963846 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -195,11 +195,6 @@ static inline int is_active_lru(enum lru_list lru)
>  	return (lru == LRU_ACTIVE_ANON || lru == LRU_ACTIVE_FILE);
>  }
>  
> -static inline int is_unevictable_lru(enum lru_list lru)
> -{
> -	return (lru == LRU_UNEVICTABLE);
> -}
> -
>  struct zone_reclaim_stat {
>  	/*
>  	 * The pageout code in vmscan.c keeps track of how many of the
> -- 
> 1.9.1
> 
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
