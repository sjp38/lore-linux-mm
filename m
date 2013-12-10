Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 78B386B0068
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 21:22:37 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id q10so6303660pdj.22
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 18:22:37 -0800 (PST)
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com. [202.81.31.140])
        by mx.google.com with ESMTPS id e8si8940762pac.285.2013.12.09.18.22.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 18:22:34 -0800 (PST)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 10 Dec 2013 12:22:28 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 997BD3578053
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 13:22:24 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBA2MCL066387980
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 13:22:12 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBA2MNgh024758
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 13:22:24 +1100
Date: Tue, 10 Dec 2013 10:22:22 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 3/7] mm/mempolicy: correct putback method for isolate
 pages if failed
Message-ID: <52a67aea.280d420a.3935.1addSMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1386580248-22431-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1386580248-22431-4-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386580248-22431-4-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Mon, Dec 09, 2013 at 06:10:44PM +0900, Joonsoo Kim wrote:
>queue_pages_range() isolates hugetlbfs pages and putback_lru_pages() can't
>handle these. We should change it to putback_movable_pages().
>
>Naoya said that it is worth going into stable, because it can break
>in-use hugepage list.
>
>Cc: <stable@vger.kernel.org> # 3.12
>Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>diff --git a/mm/mempolicy.c b/mm/mempolicy.c
>index eca4a31..6d04d37 100644
>--- a/mm/mempolicy.c
>+++ b/mm/mempolicy.c
>@@ -1318,7 +1318,7 @@ static long do_mbind(unsigned long start, unsigned long len,
> 		if (nr_failed && (flags & MPOL_MF_STRICT))
> 			err = -EIO;
> 	} else
>-		putback_lru_pages(&pagelist);
>+		putback_movable_pages(&pagelist);
>
> 	up_write(&mm->mmap_sem);
>  mpol_out:
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
