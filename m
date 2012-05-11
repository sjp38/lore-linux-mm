Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 0D1208D0001
	for <linux-mm@kvack.org>; Fri, 11 May 2012 04:13:17 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=utf-8
Received: from euspt2 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0M3U0061QMUG2S30@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 11 May 2012 09:13:28 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M3U00BJQMU2EB@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 11 May 2012 09:13:14 +0100 (BST)
Date: Fri, 11 May 2012 10:13:12 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCH] cma: fix migration mode
In-reply-to: <op.wd4gqhfm3l0zgt@mpn-glaptop>
Message-id: <02fb01cd2f4d$e8cbccb0$ba636610$%szyprowski@samsung.com>
Content-language: pl
References: <1336664003-5031-1-git-send-email-minchan@kernel.org>
 <op.wd4gqhfm3l0zgt@mpn-glaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Nazarewicz' <mina86@mina86.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Minchan Kim' <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

On Friday, May 11, 2012 4:19 AM Michal Nazarewicz wrote:

> On Thu, 10 May 2012 08:33:23 -0700, Minchan Kim <minchan@kernel.org> wrote:
> > __alloc_contig_migrate_range calls migrate_pages with wrong argument
> > for migrate_mode. Fix it.
> >
> > Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> 
> Acked-by: Michal Nazarewicz <mina86@mina86.com>
> 
> > ---
> >  mm/page_alloc.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 4d926f1..9febc62 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -5689,7 +5689,7 @@ static int __alloc_contig_migrate_range(unsigned long start, unsigned
> long end)
> > 		ret = migrate_pages(&cc.migratepages,
> >  				    __alloc_contig_migrate_alloc,
> > -				    0, false, true);
> > +				    0, false, MIGRATE_SYNC);
> >  	}
> > 	putback_lru_pages(&cc.migratepages);
> 

Thanks for the patch, I will add it to my kernel tree.

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
