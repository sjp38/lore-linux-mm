Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id EC01C6B003A
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 20:42:57 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id v10so6291079pde.13
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 17:42:57 -0800 (PST)
Received: from e28smtp04.in.ibm.com (e28smtp04.in.ibm.com. [122.248.162.4])
        by mx.google.com with ESMTPS id pj7si8848184pbc.279.2013.12.09.17.42.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 17:42:56 -0800 (PST)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 10 Dec 2013 07:12:53 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 7D479394002D
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 07:12:50 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBA1gkFp3277102
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 07:12:47 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBA1gnIL013991
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 07:12:49 +0530
Date: Tue, 10 Dec 2013 09:42:48 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 1/7] mm/migrate: add comment about permanent failure
 path
Message-ID: <52a671a0.e7da440a.46f3.272cSMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1386580248-22431-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1386580248-22431-2-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386580248-22431-2-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Mon, Dec 09, 2013 at 06:10:42PM +0900, Joonsoo Kim wrote:
>From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>
>Let's add a comment about where the failed page goes to, which makes
>code more readable.
>
>Acked-by: Christoph Lameter <cl@linux.com>
>Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>diff --git a/mm/migrate.c b/mm/migrate.c
>index 3747fcd..c6ac87a 100644
>--- a/mm/migrate.c
>+++ b/mm/migrate.c
>@@ -1123,7 +1123,12 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
> 				nr_succeeded++;
> 				break;
> 			default:
>-				/* Permanent failure */
>+				/*
>+				 * Permanent failure (-EBUSY, -ENOSYS, etc.):
>+				 * unlike -EAGAIN case, the failed page is
>+				 * removed from migration page list and not
>+				 * retried in the next outer loop.
>+				 */
> 				nr_failed++;
> 				break;
> 			}
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
