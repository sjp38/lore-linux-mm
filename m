Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 793D56B0074
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 15:10:48 -0400 (EDT)
From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?= <u.kleine-koenig@pengutronix.de>
Date: Tue, 10 Sep 2013 21:10:36 +0200
Message-Id: <1378840236-3463-1-git-send-email-u.kleine-koenig@pengutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Subject: [PATCH] let CMA depend on MMU
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kernel@pengutronix.de, linux-mm@kvack.org

This fixes compilation on my no-MMU platform when enabling CMA because
several functions/macros like pte_offset_map, mk_pte, pte_unmap or
put_anon_vma are missing.

Signed-off-by: Uwe Kleine-KA?nig <u.kleine-koenig@pengutronix.de>
---
 mm/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 6cdd270..d761f3d 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -480,7 +480,7 @@ config FRONTSWAP
 
 config CMA
 	bool "Contiguous Memory Allocator"
-	depends on HAVE_MEMBLOCK
+	depends on HAVE_MEMBLOCK && MMU
 	select MIGRATION
 	select MEMORY_ISOLATION
 	help
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
