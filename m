Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id DF1A26B0075
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 21:50:11 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id z10so6355058pdj.16
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 18:50:11 -0800 (PST)
Received: from e28smtp01.in.ibm.com (e28smtp01.in.ibm.com. [122.248.162.1])
        by mx.google.com with ESMTPS id vb7si3452858pbc.2.2013.12.09.18.50.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 18:50:10 -0800 (PST)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 10 Dec 2013 08:20:07 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 72DC2394002D
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 08:20:05 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBA2o2WR46465208
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 08:20:02 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBA2o4aR026016
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 08:20:04 +0530
Date: Tue, 10 Dec 2013 10:50:03 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 5/7] mm/compaction: respect ignore_skip_hint in
 update_pageblock_skip
Message-ID: <52a68162.67ed440a.7de4.ffffb610SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1386580248-22431-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1386580248-22431-6-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386580248-22431-6-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Mon, Dec 09, 2013 at 06:10:46PM +0900, Joonsoo Kim wrote:
>update_pageblock_skip() only fits to compaction which tries to isolate by
>pageblock unit. If isolate_migratepages_range() is called by CMA, it try to
>isolate regardless of pageblock unit and it don't reference
>get_pageblock_skip() by ignore_skip_hint. We should also respect it on
>update_pageblock_skip() to prevent from setting the wrong information.
>
>Cc: <stable@vger.kernel.org> # 3.7+
>Acked-by: Vlastimil Babka <vbabka@suse.cz>
>Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>
>diff --git a/mm/compaction.c b/mm/compaction.c
>index 805165b..f58bcd0 100644
>--- a/mm/compaction.c
>+++ b/mm/compaction.c
>@@ -134,6 +134,10 @@ static void update_pageblock_skip(struct compact_control *cc,
> 			bool migrate_scanner)
> {
> 	struct zone *zone = cc->zone;
>+
>+	if (cc->ignore_skip_hint)
>+		return;
>+
> 	if (!page)
> 		return;
>
>-- 
>1.7.9.5
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
