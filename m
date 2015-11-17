Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 8B0716B0038
	for <linux-mm@kvack.org>; Tue, 17 Nov 2015 00:17:03 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so199034460pac.3
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 21:17:03 -0800 (PST)
Received: from us-alimail-mta1.hst.scl.en.alidc.net (mail113-249.mail.alibaba.com. [205.204.113.249])
        by mx.google.com with ESMTP id nj10si55482545pbc.46.2015.11.16.21.17.01
        for <linux-mm@kvack.org>;
        Mon, 16 Nov 2015 21:17:02 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1447656686-4851-1-git-send-email-baiyaowei@cmss.chinamobile.com> <1447656686-4851-6-git-send-email-baiyaowei@cmss.chinamobile.com>
In-Reply-To: <1447656686-4851-6-git-send-email-baiyaowei@cmss.chinamobile.com>
Subject: Re: [PATCH 5/7] mm/lru: remove unused is_unevictable_lru function
Date: Tue, 17 Nov 2015 13:16:37 +0800
Message-ID: <006701d120f7$24aaa870$6dfff950$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Yaowei Bai' <baiyaowei@cmss.chinamobile.com>, akpm@linux-foundation.org
Cc: bhe@redhat.com, dan.j.williams@intel.com, dave.hansen@linux.intel.com, dave@stgolabs.net, dhowells@redhat.com, dingel@linux.vnet.ibm.com, hannes@cmpxchg.org, holt@sgi.com, iamjoonsoo.kim@lge.com, joe@perches.com, kuleshovmail@gmail.com, mgorman@suse.de, mhocko@suse.cz, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, penberg@kernel.org, rientjes@google.com, sasha.levin@oracle.com, tj@kernel.org, tony.luck@intel.com, vbabka@suse.cz, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> 
> Since commit a0b8cab3 ("mm: remove lru parameter from __pagevec_lru_add
> and remove parts of pagevec API") there's no user of this function anymore,
> so remove it.
> 
> Signed-off-by: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
> ---

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

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


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
