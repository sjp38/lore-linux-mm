Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 4A83A6B0095
	for <linux-mm@kvack.org>; Mon, 25 Jan 2010 15:38:18 -0500 (EST)
From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?= <u.kleine-koenig@pengutronix.de>
Subject: [PATCH] trivial grammar fix: if and only if
Date: Mon, 25 Jan 2010 21:38:09 +0100
Message-Id: <1264451889-10234-1-git-send-email-u.kleine-koenig@pengutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, trivial@kernel.org, Nicolas Pitre <nico@marvell.com>
List-ID: <linux-mm.kvack.org>

Signed-off-by: Uwe Kleine-KA?nig <u.kleine-koenig@pengutronix.de>
Cc: Nicolas Pitre <nico@marvell.com>
---
 mm/highmem.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/highmem.c b/mm/highmem.c
index 9c1e627..bed8a8b 100644
--- a/mm/highmem.c
+++ b/mm/highmem.c
@@ -220,7 +220,7 @@ EXPORT_SYMBOL(kmap_high);
  * @page: &struct page to pin
  *
  * Returns the page's current virtual memory address, or NULL if no mapping
- * exists.  When and only when a non null address is returned then a
+ * exists.  If and only if a non null address is returned then a
  * matching call to kunmap_high() is necessary.
  *
  * This can be called from any context.
-- 
1.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
