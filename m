Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id E81A86B0038
	for <linux-mm@kvack.org>; Tue, 16 Aug 2016 02:40:44 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id p18so191284737oic.0
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 23:40:44 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id y140si4230193iof.226.2016.08.15.23.40.43
        for <linux-mm@kvack.org>;
        Mon, 15 Aug 2016 23:40:44 -0700 (PDT)
Date: Tue, 16 Aug 2016 15:46:31 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v6 10/11] mm, compaction: require only min watermarks for
 non-costly orders
Message-ID: <20160816064630.GH17448@js1304-P5Q-DELUXE>
References: <20160810091226.6709-1-vbabka@suse.cz>
 <20160810091226.6709-11-vbabka@suse.cz>
 <20160816061636.GF17448@js1304-P5Q-DELUXE>
 <484d17e5-7294-4724-f5f9-0a15167d47ee@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <484d17e5-7294-4724-f5f9-0a15167d47ee@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Aug 16, 2016 at 08:36:12AM +0200, Vlastimil Babka wrote:
> On 08/16/2016 08:16 AM, Joonsoo Kim wrote:
> >On Wed, Aug 10, 2016 at 11:12:25AM +0200, Vlastimil Babka wrote:
> >>diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >>index 621e4211ce16..a5c0f914ec00 100644
> >>--- a/mm/page_alloc.c
> >>+++ b/mm/page_alloc.c
> >>@@ -2492,7 +2492,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
> >>
> >> 	if (!is_migrate_isolate(mt)) {
> >> 		/* Obey watermarks as if the page was being allocated */
> >>-		watermark = low_wmark_pages(zone) + (1 << order);
> >>+		watermark = min_wmark_pages(zone) + (1UL << order);
> >
> >This '1 << order' also needs some comment. Why can't we use
> >compact_gap() in this case?
> 
> This is just short-cutting the high-order watermark check to check
> only order-0, because we already know the high-order page exists.
> We can't use compact_gap() as that's too high to use for a single
> allocation watermark, since we can be already holding some free
> pages on the list. So it would defeat the gap purpose.

Oops. I missed that. Thanks for clarifying it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
