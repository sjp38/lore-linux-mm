Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id A847F6B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 06:18:24 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id u42so34865095ioi.7
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 03:18:24 -0800 (PST)
Received: from huawei.com ([45.249.212.35])
        by mx.google.com with ESMTPS id 64si16262006its.40.2017.11.27.03.18.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 03:18:23 -0800 (PST)
From: JianKang Chen <chenjiankang1@huawei.com>
Subject: [PATCH resend] mm/page_alloc: fix comment is __get_free_pages
Date: Mon, 27 Nov 2017 19:09:24 +0800
Message-ID: <1511780964-64864-1-git-send-email-chenjiankang1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, mgorman@techsingularity.net, hillf.zj@alibaba-inc.com
Cc: hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, xieyisheng1@huawei.com, guohanjun@huawei.com, wangkefeng.wang@huawei.com, chenjiankang1@huawei.com

From: Jiankang Chen <chenjiankang1@huawei.com>

__get_free_pages will return an virtual address, 
but it is not just 32-bit address, for example a 64-bit system. 
And this comment really confuse new bigenner of mm.

reported-by: Hanjun Guo <guohanjun@huawei.com>
Signed-off-by: Jiankang Chen <chenjiankang1@huawei.com>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 77e4d3c..5a7c432 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4240,7 +4240,7 @@ unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order)
 	struct page *page;
 
 	/*
-	 * __get_free_pages() returns a 32-bit address, which cannot represent
+	 * __get_free_pages() returns a virtual address, which cannot represent
 	 * a highmem page
 	 */
 	VM_BUG_ON((gfp_mask & __GFP_HIGHMEM) != 0);
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
