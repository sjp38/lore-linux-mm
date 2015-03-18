Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7335D6B006E
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 06:03:29 -0400 (EDT)
Received: by padcy3 with SMTP id cy3so38073300pad.3
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 03:03:29 -0700 (PDT)
Received: from e28smtp03.in.ibm.com (e28smtp03.in.ibm.com. [122.248.162.3])
        by mx.google.com with ESMTPS id em4si34991387pac.131.2015.03.18.03.03.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Mar 2015 03:03:28 -0700 (PDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 18 Mar 2015 15:33:24 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 6914CE0045
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 15:35:29 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t2IA351M5963930
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 15:33:05 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t2IA349u012846
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 15:33:04 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC 13/16] mm/cma: populate ZONE_CMA and use this zone when GFP_HIGHUSERMOVABLE
In-Reply-To: <1423726340-4084-14-git-send-email-iamjoonsoo.kim@lge.com>
References: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com> <1423726340-4084-14-git-send-email-iamjoonsoo.kim@lge.com>
Date: Wed, 18 Mar 2015 15:33:02 +0530
Message-ID: <878ueusjvt.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hui Zhu <zhuhui@xiaomi.com>, Gioh Kim <gioh.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Ritesh Harjani <ritesh.list@gmail.com>, Vlastimil Babka <vbabka@suse.cz>


>
>  #ifdef CONFIG_CMA
> +static void __init adjust_present_page_count(struct page *page, long count)
> +{
> +	struct zone *zone = page_zone(page);
> +
> +	zone->present_pages += count;
> +}
> +

May be adjust_page_zone_present_count() ?


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
