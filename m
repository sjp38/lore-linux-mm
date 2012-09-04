Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 186BA6B005D
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 04:27:51 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so9673000pbb.14
        for <linux-mm@kvack.org>; Tue, 04 Sep 2012 01:27:50 -0700 (PDT)
From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH] mm/memblock: Replace 0 with NULL for pointer
Date: Tue,  4 Sep 2012 13:55:05 +0530
Message-Id: <1346747105-658-1-git-send-email-sachin.kamat@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: sachin.kamat@linaro.org, patches@linaro.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>

Silences the following sparse warning:
mm/memblock.c:249:49: warning: Using plain integer as NULL pointer

Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
---
 mm/memblock.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 4d9393c..82aa349 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -246,7 +246,7 @@ static int __init_memblock memblock_double_array(struct memblock_type *type,
 				min(new_area_start, memblock.current_limit),
 				new_alloc_size, PAGE_SIZE);
 
-		new_array = addr ? __va(addr) : 0;
+		new_array = addr ? __va(addr) : NULL;
 	}
 	if (!addr) {
 		pr_err("memblock: Failed to double %s array from %ld to %ld entries !\n",
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
