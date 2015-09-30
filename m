Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id C625C6B026D
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 16:37:06 -0400 (EDT)
Received: by qkbi190 with SMTP id i190so3114731qkb.1
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 13:37:06 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 66si2416112qhh.8.2015.09.30.13.37.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Sep 2015 13:37:05 -0700 (PDT)
Date: Wed, 30 Sep 2015 13:37:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 10/10] mm, page_alloc: Only enforce watermarks for
 order-0 allocations
Message-Id: <20150930133704.b204cc34b5fac8ab8f0780c3@linux-foundation.org>
In-Reply-To: <20150930151234.GP3068@techsingularity.net>
References: <1442832762-7247-1-git-send-email-mgorman@techsingularity.net>
	<20150921120317.GC3068@techsingularity.net>
	<20150929140507.82b5e02f300038e4bb5b2493@linux-foundation.org>
	<20150930084650.GM3068@techsingularity.net>
	<560BEF08.60704@suse.cz>
	<20150930151234.GP3068@techsingularity.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 30 Sep 2015 16:12:34 +0100 Mel Gorman <mgorman@techsingularity.net> wrote:

> On Wed, Sep 30, 2015 at 04:17:44PM +0200, Vlastimil Babka wrote:
> > >---
> > >  mm/page_alloc.c | 11 ++++++++---
> > >  1 file changed, 8 insertions(+), 3 deletions(-)
> > >
> > >diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > >index 25731624d734..fedec98aafca 100644
> > >--- a/mm/page_alloc.c
> > >+++ b/mm/page_alloc.c
> > >@@ -2332,7 +2332,7 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
> > >  {
> > >  	long min = mark;
> > >  	int o;
> > >-	const bool alloc_harder = (alloc_flags & ALLOC_HARDER);
> > >+	const int alloc_harder = (alloc_flags & ALLOC_HARDER);
> > 
> > How bout the !!(alloc_flags & ALLOC_HARDER) conversion to bool? Unless it
> > forces to make the compiler some extra work...
> > 
> 
> Some people frown upon that trick as being obscure when it's not unnecessary
> and a modern compiler is meant to get it right. The int is clear and
> obvious in this context so I just went with it.

Yes, the !!  does generate extra code.  It doesn't seem worthwhile
overhead for a tiny cosmetic thing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
