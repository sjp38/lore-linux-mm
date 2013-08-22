Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id D42C96B0033
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 22:47:29 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id hi8so65461wib.15
        for <linux-mm@kvack.org>; Wed, 21 Aug 2013 19:47:28 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 22 Aug 2013 10:47:27 +0800
Message-ID: <CAPgLHd8+CD8iNZ4d7OJgc-jqd4ObgLnE0WmkGM5S98Q1TtTROQ@mail.gmail.com>
Subject: [PATCH -next] mm/page_alloc.c: remove duplicated include from page_alloc.c
From: Wei Yongjun <weiyj.lk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, jiang.liu@huawei.com, cody@linux.vnet.ibm.com, minchan@kernel.org
Cc: yongjun_wei@trendmicro.com.cn, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Remove duplicated include.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 mm/page_alloc.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index efb2ffa..4751901 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -60,7 +60,6 @@
 #include <linux/page-debug-flags.h>
 #include <linux/hugetlb.h>
 #include <linux/sched/rt.h>
-#include <linux/hugetlb.h>
 
 #include <asm/sections.h>
 #include <asm/tlbflush.h>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
