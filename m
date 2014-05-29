Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 5A1F26B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 02:45:06 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id ld10so459124pab.6
        for <linux-mm@kvack.org>; Wed, 28 May 2014 23:45:06 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id ld16si27061310pab.173.2014.05.28.23.45.04
        for <linux-mm@kvack.org>;
        Wed, 28 May 2014 23:45:05 -0700 (PDT)
Date: Thu, 29 May 2014 15:48:10 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] CMA: use MIGRATE_SYNC in alloc_contig_range()
Message-ID: <20140529064810.GA7044@js1304-P5Q-DELUXE>
References: <1401344750-3684-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20140529063505.GH10092@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140529063505.GH10092@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

On Thu, May 29, 2014 at 03:35:05PM +0900, Minchan Kim wrote:
> On Thu, May 29, 2014 at 03:25:50PM +0900, Joonsoo Kim wrote:
> > Before commit 'mm, compaction: embed migration mode in compact_control'
> > from David is merged, alloc_contig_range() used sync migration,
> > instead of sync_light migration. This doesn't break anything currently
> > because page isolation doesn't have any difference with sync and
> > sync_light, but it could in the future, so change back as it was.
> > 
> > And pass cc->mode to migrate_pages(), instead of passing MIGRATE_SYNC
> > to migrate_pages().
> > 
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Acked-by: Minchan Kim <minchan@kernel.org>

Thanks.

> 
> Hello Joonsoo,
> 
> Please Ccing me if you send patch related to CMA mm part.
> I have reviewed/fixed mm part of CMA for a long time so worth to Cced
> although I always don't have a time to look at it. :)

Okay! This is just small fix going back orignal, so I didn't cc many people
related to CMA mm part. Anyway, I'm sorry.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
