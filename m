Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id D14ED6B0032
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 05:25:36 -0400 (EDT)
Message-ID: <51FB7A94.6010308@huawei.com>
Date: Fri, 2 Aug 2013 17:23:32 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: mm/zbud: fix some trivial typos in comments
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sjenning@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hanjun Guo <guohanjun@huawei.com>

Fix some trivial typos in comments. 

Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
---
 mm/zbud.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/zbud.c b/mm/zbud.c
index ad1e781..9451361 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -16,7 +16,7 @@
  *
  * zbud works by storing compressed pages, or "zpages", together in pairs in a
  * single memory page called a "zbud page".  The first buddy is "left
- * justifed" at the beginning of the zbud page, and the last buddy is "right
+ * justified" at the beginning of the zbud page, and the last buddy is "right
  * justified" at the end of the zbud page.  The benefit is that if either
  * buddy is freed, the freed buddy space, coalesced with whatever slack space
  * that existed between the buddies, results in the largest possible free region
@@ -243,7 +243,7 @@ void zbud_destroy_pool(struct zbud_pool *pool)
  * gfp should not set __GFP_HIGHMEM as highmem pages cannot be used
  * as zbud pool pages.
  *
- * Return: 0 if success and handle is set, otherwise -EINVAL is the size or
+ * Return: 0 if success and handle is set, otherwise -EINVAL if the size or
  * gfp arguments are invalid or -ENOMEM if the pool was unable to allocate
  * a new page.
  */
-- 
1.7.1




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
