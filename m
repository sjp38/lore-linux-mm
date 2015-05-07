Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f44.google.com (mail-yh0-f44.google.com [209.85.213.44])
	by kanga.kvack.org (Postfix) with ESMTP id E606D6B0074
	for <linux-mm@kvack.org>; Thu,  7 May 2015 07:46:00 -0400 (EDT)
Received: by yhrr66 with SMTP id r66so10251015yhr.3
        for <linux-mm@kvack.org>; Thu, 07 May 2015 04:46:00 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id r132si907923yka.136.2015.05.07.04.45.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 07 May 2015 04:45:59 -0700 (PDT)
From: Xie XiuQi <xiexiuqi@huawei.com>
Subject: [PATCH v5 2/3] memory-failure: change type of action_result's param 3 to enum
Date: Thu, 7 May 2015 19:38:00 +0800
Message-ID: <1430998681-24953-3-git-send-email-xiexiuqi@huawei.com>
In-Reply-To: <1430998681-24953-1-git-send-email-xiexiuqi@huawei.com>
References: <1430998681-24953-1-git-send-email-xiexiuqi@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: n-horiguchi@ah.jp.nec.com, rostedt@goodmis.org, mingo@redhat.com
Cc: akpm@linux-foundation.org, gong.chen@linux.intel.com, bp@suse.de, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jingle.chen@huawei.com

Change type of action_result's param 3 to enum for type consistency,
and rename mf_outcome to mf_result for clearly.

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Xie XiuQi <xiexiuqi@huawei.com>
---
 include/linux/mm.h  | 2 +-
 mm/memory-failure.c | 3 ++-
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
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
