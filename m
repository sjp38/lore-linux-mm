Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id B6B7C82F66
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 10:51:44 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so75192456pac.0
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 07:51:44 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id mk6si18954609pab.21.2015.09.24.07.51.33
        for <linux-mm@kvack.org>;
        Thu, 24 Sep 2015 07:51:33 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 11/16] page-flags: define PG_swapcache behavior on compound pages
Date: Thu, 24 Sep 2015 17:50:59 +0300
Message-Id: <1443106264-78075-12-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1443106264-78075-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <20150921153509.fef7ecdf313ef74307c43b65@linux-foundation.org>
 <1443106264-78075-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Swap cannot handle compound pages so far. Transparent huge pages are
split on the way to swap.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/page-flags.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index a31d682caeb2..c933416b2f92 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -306,7 +306,7 @@ PAGEFLAG_FALSE(HighMem)
 #endif
 
 #ifdef CONFIG_SWAP
-PAGEFLAG(SwapCache, swapcache, PF_ANY)
+PAGEFLAG(SwapCache, swapcache, PF_NO_COMPOUND)
 #else
 PAGEFLAG_FALSE(SwapCache)
 #endif
-- 
2.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
