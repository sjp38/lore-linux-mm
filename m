Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id BEF5B6B00A2
	for <linux-mm@kvack.org>; Sat, 14 Feb 2015 00:02:20 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id rd3so16383832pab.4
        for <linux-mm@kvack.org>; Fri, 13 Feb 2015 21:02:20 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id qg1si390139pac.165.2015.02.13.21.02.18
        for <linux-mm@kvack.org>;
        Fri, 13 Feb 2015 21:02:19 -0800 (PST)
Message-ID: <54DED6D8.7080609@lge.com>
Date: Sat, 14 Feb 2015 14:02:16 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [RFC 13/16] mm/cma: populate ZONE_CMA and use this zone when
 GFP_HIGHUSERMOVABLE
References: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com> <1423726340-4084-14-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1423726340-4084-14-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=euc-kr
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hui Zhu <zhuhui@xiaomi.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Ritesh Harjani <ritesh.list@gmail.com>, Vlastimil Babka <vbabka@suse.cz>



2015-02-12 ?AEA 4:32?! Joonsoo Kim AI(?!)  3/4 ' +-U:
> Until now, reserved pages for CMA are managed altogether with normal
> page in the same zone. This approach has numorous problems and fixing
> them isn't easy. To fix this situation, ZONE_CMA is introduced in
> previous patch, but, not yet populated. This patch implement population
> of ZONE_CMA by stealing reserved pages from normal zones. This stealing
> break one uncertain assumption on zone, that is, zone isn't overlapped.
> In the early of this series, some check is inserted to every zone's span
> iterator to handle zone overlap so there would be no problem with
> this assumption break.
> 
> To utilize this zone, user should use GFP_HIGHUSERMOVABLE, because

I think it might be typo of GFP_HIGHUSER_MOVABLE.

> these pages are only applicable for movable type and ZONE_CMA could
> contain highmem.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
