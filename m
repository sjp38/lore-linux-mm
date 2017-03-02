Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D57106B0394
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 01:39:33 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q126so82010617pga.0
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 22:39:33 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id r1si450276pgo.42.2017.03.01.22.39.32
        for <linux-mm@kvack.org>;
        Wed, 01 Mar 2017 22:39:33 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 11/11] mm: remove SWAP_[SUCCESS|AGAIN|FAIL]
Date: Thu,  2 Mar 2017 15:39:25 +0900
Message-Id: <1488436765-32350-12-git-send-email-minchan@kernel.org>
In-Reply-To: <1488436765-32350-1-git-send-email-minchan@kernel.org>
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>

There is no user for it. Remove it.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/rmap.h | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 59d7dd7..5d6788f 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -291,11 +291,4 @@ static inline int page_mkclean(struct page *page)
 
 #endif	/* CONFIG_MMU */
 
-/*
- * Return values of try_to_unmap
- */
-#define SWAP_SUCCESS	0
-#define SWAP_AGAIN	1
-#define SWAP_FAIL	2
-
 #endif	/* _LINUX_RMAP_H */
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
