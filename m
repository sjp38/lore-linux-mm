Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 64F4C900015
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 13:12:21 -0400 (EDT)
Received: by pacwe9 with SMTP id we9so81215853pac.1
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 10:12:21 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ko6si3966559pab.165.2015.03.19.10.12.20
        for <linux-mm@kvack.org>;
        Thu, 19 Mar 2015 10:12:20 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 02/16] page-flags: trivial cleanup for PageTrans* helpers
Date: Thu, 19 Mar 2015 19:08:08 +0200
Message-Id: <1426784902-125149-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Use TESTPAGEFLAG_FALSE() to get it a bit cleaner.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/page-flags.h | 18 +++---------------
 1 file changed, 3 insertions(+), 15 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 84d10b65cec6..327aabd9792e 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -511,21 +511,9 @@ static inline int PageTransTail(struct page *page)
 }
 
 #else
-
-static inline int PageTransHuge(struct page *page)
-{
-	return 0;
-}
-
-static inline int PageTransCompound(struct page *page)
-{
-	return 0;
-}
-
-static inline int PageTransTail(struct page *page)
-{
-	return 0;
-}
+TESTPAGEFLAG_FALSE(TransHuge)
+TESTPAGEFLAG_FALSE(TransCompound)
+TESTPAGEFLAG_FALSE(TransTail)
 #endif
 
 /*
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
