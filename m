Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 2D6A56B005D
	for <linux-mm@kvack.org>; Tue, 18 Dec 2012 04:58:07 -0500 (EST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MF8003CJ13RP780@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 18 Dec 2012 10:00:41 +0000 (GMT)
Received: from [127.0.0.1] ([106.116.147.30])
 by eusync2.samsung.com (Oracle Communications Messaging Server 7u4-23.01
 (7.0.4.23.0) 64bit (built Aug 10 2011))
 with ESMTPA id <0MF80017H10S0X60@eusync2.samsung.com> for linux-mm@kvack.org;
 Tue, 18 Dec 2012 09:58:05 +0000 (GMT)
Message-id: <50D03E2C.20508@samsung.com>
Date: Tue, 18 Dec 2012 10:58:04 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH] CMA: call to putback_lru_pages
References: 
 <1355779504-30798-1-git-send-email-srinivas.pandruvada@linux.intel.com>
 <xa1tlicwiagh.fsf@mina86.com>
In-reply-to: <xa1tlicwiagh.fsf@mina86.com>
Content-type: text/plain; charset=UTF-8; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Srinivas Pandruvada <srinivas.pandruvada@linux.intel.com>, linux-mm@kvack.org

Hello,

On 12/17/2012 11:24 PM, Michal Nazarewicz wrote:
> [+marek]
>
> On Mon, Dec 17 2012, Srinivas Pandruvada wrote:
> > As per documentation and other places calling putback_lru_pages,
> > on error only, except for CMA. I am not sure this is a problem
> > for CMA or not.
>
> If ret >= 0 than the list is empty anyway so the effect of this patch is
> to save a function call.  It's also true that other callers call it only
> on error so __alloc_contig_migrate_range() is an odd man out here.  As
> such:
>
> Acked-by: Michal Nazarewicz <mina86@mina86.com>

Like Michal said, this is just a code cleanup without any functional change.

Acked-by: Marek Szyprowski <m.szyprowski@samsung.com>

> > Signed-off-by: Srinivas Pandruvada <srinivas.pandruvada@linux.intel.com>
> > ---
> >  mm/page_alloc.c | 4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> >
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 83637df..5a887bf 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -5802,8 +5802,8 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
> >  				    alloc_migrate_target,
> >  				    0, false, MIGRATE_SYNC);
> >  	}
> > -
> > -	putback_movable_pages(&cc->migratepages);
> > +	if (ret < 0)
> > +		putback_movable_pages(&cc->migratepages);
> >  	return ret > 0 ? 0 : ret;
> >  }
>

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
