Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id E142F6B0038
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 11:48:25 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so163400900wib.0
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 08:48:25 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id aq6si35107586wjc.144.2015.07.28.08.48.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Tue, 28 Jul 2015 08:48:23 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 2A70A9917C
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 15:48:22 +0000 (UTC)
Date: Tue, 28 Jul 2015 16:48:20 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 05/10] mm, page_alloc: Remove unnecessary updating of GFP
 flags during normal operation
Message-ID: <20150728154819.GE2660@techsingularity.net>
References: <1437379219-9160-1-git-send-email-mgorman@suse.com>
 <1437379219-9160-6-git-send-email-mgorman@suse.com>
 <55B78545.8000906@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <55B78545.8000906@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Pintu Kumar <pintu.k@samsung.com>, Xishi Qiu <qiuxishi@huawei.com>, Gioh Kim <gioh.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>

On Tue, Jul 28, 2015 at 03:36:05PM +0200, Vlastimil Babka wrote:
> >--- a/mm/page_alloc.c
> >+++ b/mm/page_alloc.c
> >@@ -124,7 +124,9 @@ unsigned long totalcma_pages __read_mostly;
> >  unsigned long dirty_balance_reserve __read_mostly;
> >
> >  int percpu_pagelist_fraction;
> >-gfp_t gfp_allowed_mask __read_mostly = GFP_BOOT_MASK;
> >+
> >+gfp_t __gfp_allowed_mask __read_mostly = GFP_BOOT_MASK;
> >+struct static_key gfp_restricted_key __read_mostly = STATIC_KEY_INIT_TRUE;
> 
> ... and here it's combined with STATIC_KEY_INIT_TRUE. I've suspected
> that this is not allowed, which Peter confirmed on IRC.
> 

Thanks because I was not aware of hazards of that nature. I'll drop the
jump-label related patches from the series until the patches related to
the correct idiom are finalised. The micro-optimisations are not the
main point of this series and the savings are tiny.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
