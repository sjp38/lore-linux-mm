Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 91FA482F66
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 10:51:30 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so75319887pad.1
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 07:51:30 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id mk6si18954609pab.21.2015.09.24.07.51.29
        for <linux-mm@kvack.org>;
        Thu, 24 Sep 2015 07:51:29 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 01/16] page-flags: trivial cleanup for PageTrans* helpers
Date: Thu, 24 Sep 2015 17:50:49 +0300
Message-Id: <1443106264-78075-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1443106264-78075-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <20150921153509.fef7ecdf313ef74307c43b65@linux-foundation.org>
 <1443106264-78075-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Use TESTPAGEFLAG_FALSE() to get it a bit cleaner.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/page-flags.h | 18 +++---------------
 1 file changed, 3 insertions(+), 15 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 4fdfb5ed4b43..815246a80e2d 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -485,21 +485,9 @@ static inline int PageTransTail(struct page *page)
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
2.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
