Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id AED076B0033
	for <linux-mm@kvack.org>; Sat, 25 Nov 2017 01:39:10 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id z30so12758506otd.9
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 22:39:10 -0800 (PST)
Received: from szxga04-in.huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id n2si9383003oig.394.2017.11.24.22.39.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Nov 2017 22:39:09 -0800 (PST)
From: JianKang Chen <chenjiankang1@huawei.com>
Subject: [PATCH] mm/page_alloc: fix comment is __get_free_pages
Date: Sat, 25 Nov 2017 14:29:19 +0800
Message-ID: <1511591359-11448-1-git-send-email-chenjiankang1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, mgorman@techsingularity.net, hillf.zj@alibaba-inc.com
Cc: hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, xieyisheng1@huawei.com, guohanjun@huawei.com, wangkefeng.wang@huawei.com

From: c00426987 <c00426987@huawei.com>

__get_free_pages will return an 64bit address in 64bit System
like arm64 or x86_64. And this comment really
confuse new bigenner of mm.

reported-by: Hanjun Guo <guohanjun@huawei.com>
Signed-off-by: Chen Jiankang <chenjiankang1@huawei.com>
---
 mm/page_alloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 77e4d3c..b847b24 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4240,8 +4240,8 @@ unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order)
 	struct page *page;
 
 	/*
-	 * __get_free_pages() returns a 32-bit address, which cannot represent
-	 * a highmem page
+	 * __get_free_pages() returns a virtual address, which
+	 * cannot represent a highmem page
 	 */
 	VM_BUG_ON((gfp_mask & __GFP_HIGHMEM) != 0);
 
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
