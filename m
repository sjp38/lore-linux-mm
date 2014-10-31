Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 4367328001E
	for <linux-mm@kvack.org>; Fri, 31 Oct 2014 06:37:35 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id y10so7101497pdj.0
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 03:37:34 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id la9si9011433pbc.16.2014.10.31.03.37.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 31 Oct 2014 03:37:34 -0700 (PDT)
From: w00218164 <weiyuan.wei@huawei.com>
Subject: [PATCH] mm: Fix a spelling mistake
Date: Fri, 31 Oct 2014 18:37:53 +0800
Message-ID: <1414751873-19981-1-git-send-email-weiyuan.wei@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, rientjes@google.com, hannes@cmpxchg.org, riel@redhat.com, vbabka@suse.cz, sasha.levin@oracle.com
Cc: lizefan@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Wei Yuan <weiyuan.wei@huawei.com>

This patch fixes a spelling mistake in func
__zone_watermark_ok, which may was wrongly spelled my.

Signed-off-by Wei Yuan <weiyuan.wei@huawei.com>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9cd36b8..f3ce2e1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1714,7 +1714,7 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
 			unsigned long mark, int classzone_idx, int alloc_flags,
 			long free_pages)
 {
-	/* free_pages my go negative - that's OK */
+	/* free_pages may go negative - that's OK */
 	long min = mark;
 	int o;
 	long free_cma = 0;
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
