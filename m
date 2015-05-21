Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id D48F86B0148
	for <linux-mm@kvack.org>; Wed, 20 May 2015 23:50:22 -0400 (EDT)
Received: by obblk2 with SMTP id lk2so51880774obb.0
        for <linux-mm@kvack.org>; Wed, 20 May 2015 20:50:22 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id wz3si11911647obc.33.2015.05.20.20.50.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 20 May 2015 20:50:21 -0700 (PDT)
From: Xie XiuQi <xiexiuqi@huawei.com>
Subject: [PATCH v6 2/5] memory-failure: change type of action_result's param 3 to enum
Date: Thu, 21 May 2015 11:41:22 +0800
Message-ID: <1432179685-11369-3-git-send-email-xiexiuqi@huawei.com>
In-Reply-To: <1432179685-11369-1-git-send-email-xiexiuqi@huawei.com>
References: <1432179685-11369-1-git-send-email-xiexiuqi@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com
Cc: rostedt@goodmis.org, gong.chen@linux.intel.com, mingo@redhat.com, bp@suse.de, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jingle.chen@huawei.com, sfr@canb.auug.org.au, rdunlap@infradead.org, jim.epost@gmail.com

Change type of action_result's param 3 to enum for type consistency,
and rename mf_outcome to mf_result for clearly.

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Xie XiuQi <xiexiuqi@huawei.com>
---
 include/linux/mm.h  |    2 +-
 mm/memory-failure.c |    3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 3abf13c..0632dea 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2156,7 +2156,7 @@ extern int soft_offline_page(struct page *page, int flags);
 /*
  * Error handlers for various types of pages.
  */
-enum mf_outcome {
+enum mf_result {
 	MF_IGNORED,	/* Error: cannot be handled */
 	MF_FAILED,	/* Error: handling failed */
 	MF_DELAYED,	/* Will be handled later */
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 5650dec..a3f7ea2 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -847,7 +847,8 @@ static struct page_state {
  * "Dirty/Clean" indication is not 100% accurate due to the possibility of
  * setting PG_dirty outside page lock. See also comment above set_page_dirty().
  */
-static void action_result(unsigned long pfn, enum mf_action_page_type type, int result)
+static void action_result(unsigned long pfn, enum mf_action_page_type type,
+			  enum mf_result result)
 {
 	pr_err("MCE %#lx: recovery action for %s: %s\n",
 		pfn, action_page_types[type], action_name[result]);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
