Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 6B6A46B0038
	for <linux-mm@kvack.org>; Tue, 17 Feb 2015 00:22:37 -0500 (EST)
Received: by pdjg10 with SMTP id g10so41367581pdj.1
        for <linux-mm@kvack.org>; Mon, 16 Feb 2015 21:22:37 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id ja3si255395pbc.81.2015.02.16.21.22.35
        for <linux-mm@kvack.org>;
        Mon, 16 Feb 2015 21:22:36 -0800 (PST)
Date: Tue, 17 Feb 2015 14:25:07 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC 13/16] mm/cma: populate ZONE_CMA and use this zone when
 GFP_HIGHUSERMOVABLE
Message-ID: <20150217052506.GC15413@js1304-P5Q-DELUXE>
References: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1423726340-4084-14-git-send-email-iamjoonsoo.kim@lge.com>
 <54DED6D8.7080609@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <54DED6D8.7080609@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hui Zhu <zhuhui@xiaomi.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Ritesh Harjani <ritesh.list@gmail.com>, Vlastimil Babka <vbabka@suse.cz>

On Sat, Feb 14, 2015 at 02:02:16PM +0900, Gioh Kim wrote:
> 
> 
> 2015-02-12 i??i?? 4:32i?? Joonsoo Kim i?'(e??) i?' e,?:
> > Until now, reserved pages for CMA are managed altogether with normal
> > page in the same zone. This approach has numorous problems and fixing
> > them isn't easy. To fix this situation, ZONE_CMA is introduced in
> > previous patch, but, not yet populated. This patch implement population
> > of ZONE_CMA by stealing reserved pages from normal zones. This stealing
> > break one uncertain assumption on zone, that is, zone isn't overlapped.
> > In the early of this series, some check is inserted to every zone's span
> > iterator to handle zone overlap so there would be no problem with
> > this assumption break.
> > 
> > To utilize this zone, user should use GFP_HIGHUSERMOVABLE, because
> 
> I think it might be typo of GFP_HIGHUSER_MOVABLE.
> 

Yes, I will correct next time.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
