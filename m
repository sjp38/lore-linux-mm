Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id F08BC6B007E
	for <linux-mm@kvack.org>; Thu, 12 May 2016 23:59:44 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id xm6so132062703pab.3
        for <linux-mm@kvack.org>; Thu, 12 May 2016 20:59:44 -0700 (PDT)
Received: from out4133-66.mail.aliyun.com (out4133-66.mail.aliyun.com. [42.120.133.66])
        by mx.google.com with ESMTP id u62si21750659pfi.160.2016.05.12.20.59.40
        for <linux-mm@kvack.org>;
        Thu, 12 May 2016 20:59:44 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1463051677-29418-1-git-send-email-mhocko@kernel.org> <1463051677-29418-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1463051677-29418-2-git-send-email-mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mmotm: mm-oom-rework-oom-detection-fix
Date: Fri, 13 May 2016 11:59:28 +0800
Message-ID: <02ed01d1accb$d92e16f0$8b8a44d0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Linus Torvalds' <torvalds@linux-foundation.org>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Mel Gorman' <mgorman@suse.de>, 'David Rientjes' <rientjes@google.com>, 'Tetsuo Handa' <penguin-kernel@I-love.SAKURA.ne.jp>, 'Joonsoo Kim' <js1304@gmail.com>, 'Vlastimil Babka' <vbabka@suse.cz>, linux-mm@kvack.org, 'LKML' <linux-kernel@vger.kernel.org>, 'Michal Hocko' <mhocko@suse.com>

> From: Michal Hocko <mhocko@suse.com>
> 
> watermark check should use classzone_idx rather than high_zoneidx
> to check reserves against the correct (preferred) zone.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

>  mm/page_alloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 0d9008042efa..620ec002aea2 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3496,7 +3496,7 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
>  		 * available?
>  		 */
>  		if (__zone_watermark_ok(zone, order, min_wmark_pages(zone),
> -				ac->high_zoneidx, alloc_flags, available)) {
> +				ac_classzone_idx(ac), alloc_flags, available)) {
>  			/*
>  			 * If we didn't make any progress and have a lot of
>  			 * dirty + writeback pages then we should wait for
> --
> 2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
