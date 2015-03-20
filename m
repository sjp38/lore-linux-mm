Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id C77256B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 00:28:25 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so96918466pdb.1
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 21:28:25 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id ry1si6760834pab.199.2015.03.19.21.28.23
        for <linux-mm@kvack.org>;
        Thu, 19 Mar 2015 21:28:24 -0700 (PDT)
Date: Fri, 20 Mar 2015 13:28:37 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC 13/16] mm/cma: populate ZONE_CMA and use this zone when
 GFP_HIGHUSERMOVABLE
Message-ID: <20150320042836.GA2021@js1304-P5Q-DELUXE>
References: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1423726340-4084-14-git-send-email-iamjoonsoo.kim@lge.com>
 <878ueusjvt.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <878ueusjvt.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hui Zhu <zhuhui@xiaomi.com>, Gioh Kim <gioh.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Ritesh Harjani <ritesh.list@gmail.com>, Vlastimil Babka <vbabka@suse.cz>

On Wed, Mar 18, 2015 at 03:33:02PM +0530, Aneesh Kumar K.V wrote:
> 
> >
> >  #ifdef CONFIG_CMA
> > +static void __init adjust_present_page_count(struct page *page, long count)
> > +{
> > +	struct zone *zone = page_zone(page);
> > +
> > +	zone->present_pages += count;
> > +}
> > +
> 
> May be adjust_page_zone_present_count() ?
> 

Hello,

This name is motivated from adjust_managed_page_count() which handles
zone's managed_page change.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
