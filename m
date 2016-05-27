Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id DD9B36B025F
	for <linux-mm@kvack.org>; Fri, 27 May 2016 01:31:25 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id i127so85050449ita.2
        for <linux-mm@kvack.org>; Thu, 26 May 2016 22:31:25 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 135si1545761itf.96.2016.05.26.22.31.24
        for <linux-mm@kvack.org>;
        Thu, 26 May 2016 22:31:25 -0700 (PDT)
Date: Fri, 27 May 2016 14:32:23 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 5/6] mm/cma: remove MIGRATE_CMA
Message-ID: <20160527053223.GB13661@js1304-P5Q-DELUXE>
References: <1464243748-16367-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1464243748-16367-6-git-send-email-iamjoonsoo.kim@lge.com>
 <5747A600.3050800@hisilicon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5747A600.3050800@hisilicon.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Feng <puck.chen@hisilicon.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Rui Teng <rui.teng@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, qijiwen@hisilicon.com, Zhuangluan Su <suzhuangluan@hisilicon.com>, Dan Zhao <dan.zhao@hisilicon.com>

On Fri, May 27, 2016 at 09:42:24AM +0800, Chen Feng wrote:
> Hi Joonsoo,
> > -/* Free whole pageblock and set its migration type to MIGRATE_CMA. */
> > +/* Free whole pageblock and set its migration type to MIGRATE_MOVABLE. */
> >  void __init init_cma_reserved_pageblock(struct page *page)
> >  {
> >  	unsigned i = pageblock_nr_pages;
> > @@ -1605,7 +1602,7 @@ void __init init_cma_reserved_pageblock(struct page *page)
> >  
> >  	adjust_present_page_count(page, pageblock_nr_pages);
> >  
> > -	set_pageblock_migratetype(page, MIGRATE_CMA);
> > +	set_pageblock_migratetype(page, MIGRATE_MOVABLE);
> 
> I have a question here, if the ZONE_CMA pages are all movable.
> 
> Then the unmovable alloc will also use CMA memory. Is this right?

No, previous patch changes that the CMA memory is on separate zone,
ZONE_CMA. We allow that zone when gfp is GFP_HIGHUSER_MOVABLE so
unmovable allocation cannot happen on CMA memory.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
