Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 6EEAD6B026D
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 10:51:20 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so75183145pac.0
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 07:51:20 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id rn14si4045584pab.184.2015.09.24.07.51.19
        for <linux-mm@kvack.org>;
        Thu, 24 Sep 2015 07:51:19 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 10/16] page-flags: define PG_swapbacked behavior on compound pages
Date: Thu, 24 Sep 2015 17:50:58 +0300
Message-Id: <1443106264-78075-11-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1443106264-78075-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <20150921153509.fef7ecdf313ef74307c43b65@linux-foundation.org>
 <1443106264-78075-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

PG_swapbacked is used for transparent huge pages. For head pages only.
Let's use PF_NO_TAIL policy.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/page-flags.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 5ba8130fffb5..a31d682caeb2 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -266,9 +266,9 @@ PAGEFLAG(Foreign, foreign, PF_NO_COMPOUND);
 
 PAGEFLAG(Reserved, reserved, PF_NO_COMPOUND)
 	__CLEARPAGEFLAG(Reserved, reserved, PF_NO_COMPOUND)
-PAGEFLAG(SwapBacked, swapbacked, PF_ANY)
-	__CLEARPAGEFLAG(SwapBacked, swapbacked, PF_ANY)
-	__SETPAGEFLAG(SwapBacked, swapbacked, PF_ANY)
+PAGEFLAG(SwapBacked, swapbacked, PF_NO_TAIL)
+	__CLEARPAGEFLAG(SwapBacked, swapbacked, PF_NO_TAIL)
+	__SETPAGEFLAG(SwapBacked, swapbacked, PF_NO_TAIL)
 
 /*
  * Private page markings that may be used by the filesystem that owns the page
-- 
2.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
