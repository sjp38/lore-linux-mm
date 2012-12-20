Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 3893B6B0069
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 14:14:15 -0500 (EST)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] slob: use DIV_ROUND_UP where possible
Date: Thu, 20 Dec 2012 14:11:39 -0500
Message-Id: <1356030701-16284-31-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1356030701-16284-1-git-send-email-sasha.levin@oracle.com>
References: <1356030701-16284-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Sasha Levin <sasha.levin@oracle.com>

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 mm/slob.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slob.c b/mm/slob.c
index a99fdf7..f729c46 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -122,7 +122,7 @@ static inline void clear_slob_page_free(struct page *sp)
 }
 
 #define SLOB_UNIT sizeof(slob_t)
-#define SLOB_UNITS(size) (((size) + SLOB_UNIT - 1)/SLOB_UNIT)
+#define SLOB_UNITS(size) DIV_ROUND_UP(size, SLOB_UNIT)
 
 /*
  * struct slob_rcu is inserted at the tail of allocated slob blocks, which
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
