Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D1619200013
	for <linux-mm@kvack.org>; Mon, 10 May 2010 06:02:39 -0400 (EDT)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 06/25] lmb: Expose LMB_ALLOC_ANYWHERE
Date: Mon, 10 May 2010 19:38:40 +1000
Message-Id: <1273484339-28911-7-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1273484339-28911-6-git-send-email-benh@kernel.crashing.org>
References: <1273484339-28911-1-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-2-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-3-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-4-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-5-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-6-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, tglx@linuxtronix.de, mingo@elte.hu, davem@davemloft.net, lethal@linux-sh.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 arch/powerpc/mm/hash_utils_64.c |    2 +-
 include/linux/lmb.h             |    1 +
 lib/lmb.c                       |    2 --
 3 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
index 2fdeedf..28838e3 100644
--- a/arch/powerpc/mm/hash_utils_64.c
+++ b/arch/powerpc/mm/hash_utils_64.c
@@ -625,7 +625,7 @@ static void __init htab_initialize(void)
 		if (machine_is(cell))
 			limit = 0x80000000;
 		else
-			limit = 0;
+			limit = LMB_ALLOC_ANYWHERE;
 
 		table = lmb_alloc_base(htab_size_bytes, htab_size_bytes, limit);
 
diff --git a/include/linux/lmb.h b/include/linux/lmb.h
index 9caa67a..f0d2cab 100644
--- a/include/linux/lmb.h
+++ b/include/linux/lmb.h
@@ -50,6 +50,7 @@ extern u64 __init lmb_alloc_nid(u64 size, u64 align, int nid);
 extern u64 __init lmb_alloc(u64 size, u64 align);
 extern u64 __init lmb_alloc_base(u64 size,
 		u64, u64 max_addr);
+#define LMB_ALLOC_ANYWHERE	0
 extern u64 __init __lmb_alloc_base(u64 size,
 		u64 align, u64 max_addr);
 extern u64 __init lmb_phys_mem_size(void);
diff --git a/lib/lmb.c b/lib/lmb.c
index 00d5808..bd81266 100644
--- a/lib/lmb.c
+++ b/lib/lmb.c
@@ -15,8 +15,6 @@
 #include <linux/bitops.h>
 #include <linux/lmb.h>
 
-#define LMB_ALLOC_ANYWHERE	0
-
 struct lmb lmb;
 
 static int lmb_debug;
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
