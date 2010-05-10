Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8ACC36200BF
	for <linux-mm@kvack.org>; Mon, 10 May 2010 05:39:38 -0400 (EDT)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 02/25] lmb: No reason to include asm/lmb.h late
Date: Mon, 10 May 2010 19:38:36 +1000
Message-Id: <1273484339-28911-3-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1273484339-28911-2-git-send-email-benh@kernel.crashing.org>
References: <1273484339-28911-1-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-2-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, tglx@linuxtronix.de, mingo@elte.hu, davem@davemloft.net, lethal@linux-sh.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 include/linux/lmb.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/lmb.h b/include/linux/lmb.h
index d225d78..de8031f 100644
--- a/include/linux/lmb.h
+++ b/include/linux/lmb.h
@@ -16,6 +16,8 @@
 #include <linux/init.h>
 #include <linux/mm.h>
 
+#include <asm/lmb.h>
+
 #define MAX_LMB_REGIONS 128
 
 struct lmb_region {
@@ -82,8 +84,6 @@ lmb_end_pfn(struct lmb_type *type, unsigned long region_nr)
 	       lmb_size_pages(type, region_nr);
 }
 
-#include <asm/lmb.h>
-
 #endif /* __KERNEL__ */
 
 #endif /* _LINUX_LMB_H */
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
