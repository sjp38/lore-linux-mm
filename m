Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 641926B0254
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 12:18:10 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so122033408wic.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 09:18:09 -0700 (PDT)
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com. [209.85.212.171])
        by mx.google.com with ESMTPS id ge18si32208778wjc.81.2015.09.21.09.18.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 09:18:08 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so153987622wic.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 09:18:08 -0700 (PDT)
Date: Mon, 21 Sep 2015 18:18:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm/vmscan: make inactive_anon_is_low_global return
 directly
Message-ID: <20150921161806.GE19811@dhcp22.suse.cz>
References: <1442404800-4051-1-git-send-email-bywxiaobai@163.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442404800-4051-1-git-send-email-bywxiaobai@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yaowei Bai <bywxiaobai@163.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, oleg@redhat.com, vbabka@suse.cz, iamjoonsoo.kim@lge.com, zhangyanfei@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 16-09-15 19:59:58, Yaowei Bai wrote:
> Delete unnecessary if to let inactive_anon_is_low_global return
> directly.
> 
> No functional changes.

Is this really an improvement? I am not so sure. If anything the
function has a bool return semantic...

> Signed-off-by: Yaowei Bai <bywxiaobai@163.com>
> ---
>  mm/vmscan.c | 5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 2d978b2..2785d8e 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1866,10 +1866,7 @@ static int inactive_anon_is_low_global(struct zone *zone)
>  	active = zone_page_state(zone, NR_ACTIVE_ANON);
>  	inactive = zone_page_state(zone, NR_INACTIVE_ANON);
>  
> -	if (inactive * zone->inactive_ratio < active)
> -		return 1;
> -
> -	return 0;
> +	return inactive * zone->inactive_ratio < active;
>  }
>  
>  /**
> -- 
> 1.9.1
> 
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
