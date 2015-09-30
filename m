Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 314A86B026F
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 11:12:38 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so199950878wic.1
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 08:12:37 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id fb6si1373402wib.38.2015.09.30.08.12.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Wed, 30 Sep 2015 08:12:36 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id D963E98B36
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 15:12:35 +0000 (UTC)
Date: Wed, 30 Sep 2015 16:12:34 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 10/10] mm, page_alloc: Only enforce watermarks for
 order-0 allocations
Message-ID: <20150930151234.GP3068@techsingularity.net>
References: <1442832762-7247-1-git-send-email-mgorman@techsingularity.net>
 <20150921120317.GC3068@techsingularity.net>
 <20150929140507.82b5e02f300038e4bb5b2493@linux-foundation.org>
 <20150930084650.GM3068@techsingularity.net>
 <560BEF08.60704@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <560BEF08.60704@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Sep 30, 2015 at 04:17:44PM +0200, Vlastimil Babka wrote:
> >---
> >  mm/page_alloc.c | 11 ++++++++---
> >  1 file changed, 8 insertions(+), 3 deletions(-)
> >
> >diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >index 25731624d734..fedec98aafca 100644
> >--- a/mm/page_alloc.c
> >+++ b/mm/page_alloc.c
> >@@ -2332,7 +2332,7 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
> >  {
> >  	long min = mark;
> >  	int o;
> >-	const bool alloc_harder = (alloc_flags & ALLOC_HARDER);
> >+	const int alloc_harder = (alloc_flags & ALLOC_HARDER);
> 
> How bout the !!(alloc_flags & ALLOC_HARDER) conversion to bool? Unless it
> forces to make the compiler some extra work...
> 

Some people frown upon that trick as being obscure when it's not unnecessary
and a modern compiler is meant to get it right. The int is clear and
obvious in this context so I just went with it.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
