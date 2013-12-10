Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9210F6B0085
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 03:48:58 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id y13so6834951pdi.5
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 00:48:58 -0800 (PST)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id bc2si9817370pad.71.2013.12.10.00.48.54
        for <linux-mm@kvack.org>;
        Tue, 10 Dec 2013 00:48:57 -0800 (PST)
Date: Tue, 10 Dec 2013 17:51:47 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 4/7] mm/migrate: remove putback_lru_pages, fix comment
 on putback_movable_pages
Message-ID: <20131210085147.GD24992@lge.com>
References: <1386580248-22431-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1386580248-22431-5-git-send-email-iamjoonsoo.kim@lge.com>
 <52a67d8c.6966420a.7a42.555fSMTPIN_ADDED_BROKEN@mx.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52a67d8c.6966420a.7a42.555fSMTPIN_ADDED_BROKEN@mx.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

> >@@ -1704,6 +1688,12 @@ int migrate_misplaced_page(struct page *page, struct vm_area_struct *vma,
> > 	nr_remaining = migrate_pages(&migratepages, alloc_misplaced_dst_page,
> > 				     node, MIGRATE_ASYNC, MR_NUMA_MISPLACED);
> > 	if (nr_remaining) {
> >+		if (!list_empty(&migratepages)) {
> >+			list_del(&page->lru);
> >+			dec_zone_page_state(page, NR_ISOLATED_ANON +
> >+					page_is_file_cache(page));
> >+			putback_lru_page(page);
> >+		}
> > 		putback_lru_pages(&migratepages);
> 
> You should remove this line. Otherwise,

Yes, you are right. I will send next version. T_T

> 
> Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
