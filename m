Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 951A328095A
	for <linux-mm@kvack.org>; Sun, 12 Mar 2017 20:36:01 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id w189so271234282pfb.4
        for <linux-mm@kvack.org>; Sun, 12 Mar 2017 17:36:01 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 1si16563204plk.2.2017.03.12.17.36.00
        for <linux-mm@kvack.org>;
        Sun, 12 Mar 2017 17:36:00 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v1 10/10] mm: remove SWAP_[SUCCESS|AGAIN|FAIL]
Date: Mon, 13 Mar 2017 09:35:53 +0900
Message-ID: <1489365353-28205-11-git-send-email-minchan@kernel.org>
In-Reply-To: <1489365353-28205-1-git-send-email-minchan@kernel.org>
References: <1489365353-28205-1-git-send-email-minchan@kernel.org>
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
