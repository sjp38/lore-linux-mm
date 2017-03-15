Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 42E936B0392
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 01:25:01 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id q126so15086395pga.0
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 22:25:01 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id p19si967718pli.148.2017.03.14.22.24.59
        for <linux-mm@kvack.org>;
        Tue, 14 Mar 2017 22:25:00 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 10/10] mm: remove SWAP_[SUCCESS|AGAIN|FAIL]
Date: Wed, 15 Mar 2017 14:24:53 +0900
Message-ID: <1489555493-14659-11-git-send-email-minchan@kernel.org>
In-Reply-To: <1489555493-14659-1-git-send-email-minchan@kernel.org>
References: <1489555493-14659-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>

There is no user for it. Remove it.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/rmap.h | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 13ed232..43ef2c3 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -295,11 +295,4 @@ static inline int page_mkclean(struct page *page)
 
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
