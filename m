Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3DA106B0253
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 05:30:57 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id a2so114896803lfe.0
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 02:30:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id uk8si25235105wjb.66.2016.06.27.02.30.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Jun 2016 02:30:55 -0700 (PDT)
Subject: Re: [PATCH v3 4/6] mm/cma: remove ALLOC_CMA
References: <1464243748-16367-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1464243748-16367-5-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5848e9f2-fd49-059e-fe57-aee6cd70c371@suse.cz>
Date: Mon, 27 Jun 2016 11:30:52 +0200
MIME-Version: 1.0
In-Reply-To: <1464243748-16367-5-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Rui Teng <rui.teng@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 05/26/2016 08:22 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> Now, all reserved pages for CMA region are belong to the ZONE_CMA
> and it only serves for GFP_HIGHUSER_MOVABLE. Therefore, we don't need to
> consider ALLOC_CMA at all.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  mm/internal.h   |  3 +--
>  mm/page_alloc.c | 27 +++------------------------
>  2 files changed, 4 insertions(+), 26 deletions(-)
>

[...]

> @@ -2833,10 +2827,8 @@ bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
>  		}
>
>  #ifdef CONFIG_CMA
> -		if ((alloc_flags & ALLOC_CMA) &&
> -		    !list_empty(&area->free_list[MIGRATE_CMA])) {
> +		if (!list_empty(&area->free_list[MIGRATE_CMA]))
>  			return true;
> -		}
>  #endif

Nitpick: it would be more logical to remove the whole block in this 
patch, as removing ALLOC_CMA means it's effectively false? Also less churn.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
