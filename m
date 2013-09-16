Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 66F3F6B008A
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 08:42:02 -0400 (EDT)
Message-ID: <5236FC88.6050409@huawei.com>
Date: Mon, 16 Sep 2013 20:41:44 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm/ksm: return NULL when doesn't get mergeable page
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

In get_mergeable_page() local variable page is not initialized,
it may hold a garbage value, when find_mergeable_vma() return NULL,
get_mergeable_page() may return a garbage value to the caller.

So initialize page as NULL.

Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
---
 mm/ksm.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index b6afe0c..87efbae 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -460,7 +460,7 @@ static struct page *get_mergeable_page(struct rmap_item *rmap_item)
 	struct mm_struct *mm = rmap_item->mm;
 	unsigned long addr = rmap_item->address;
 	struct vm_area_struct *vma;
-	struct page *page;
+	struct page *page = NULL;
 
 	down_read(&mm->mmap_sem);
 	vma = find_mergeable_vma(mm, addr);
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
