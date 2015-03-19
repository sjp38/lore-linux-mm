Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id A310B900015
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 13:10:46 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so81815100pdb.1
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 10:10:46 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id g5si4051260pda.134.2015.03.19.10.10.45
        for <linux-mm@kvack.org>;
        Thu, 19 Mar 2015 10:10:45 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 10/16] page-flags: define PG_swapbacked behavior on compound pages
Date: Thu, 19 Mar 2015 19:08:16 +0200
Message-Id: <1426784902-125149-11-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

PG_swapbacked is used for transparent huge pages. For head pages only.
Let's use NO_TAIL policy.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/page-flags.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index be691551896b..d1d08508984d 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -290,9 +290,9 @@ PAGEFLAG(Foreign, foreign, NO_COMPOUND)
 
 PAGEFLAG(Reserved, reserved, NO_COMPOUND)
 	__CLEARPAGEFLAG(Reserved, reserved, NO_COMPOUND)
-PAGEFLAG(SwapBacked, swapbacked, ANY)
-	__CLEARPAGEFLAG(SwapBacked, swapbacked, ANY)
-	__SETPAGEFLAG(SwapBacked, swapbacked, ANY)
+PAGEFLAG(SwapBacked, swapbacked, NO_TAIL)
+	__CLEARPAGEFLAG(SwapBacked, swapbacked, NO_TAIL)
+	__SETPAGEFLAG(SwapBacked, swapbacked, NO_TAIL)
 
 /*
  * Private page markings that may be used by the filesystem that owns the page
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
