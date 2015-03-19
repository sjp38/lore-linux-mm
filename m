Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id A08D36B006E
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 13:08:38 -0400 (EDT)
Received: by obcxo2 with SMTP id xo2so59503285obc.0
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 10:08:38 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id er5si3802589pad.227.2015.03.19.10.08.37
        for <linux-mm@kvack.org>;
        Thu, 19 Mar 2015 10:08:38 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 09/16] page-flags: define PG_reserved behavior on compound pages
Date: Thu, 19 Mar 2015 19:08:15 +0200
Message-Id: <1426784902-125149-10-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

As far as I can see there's no users of PG_reserved on compound pages.
Let's use NO_COMPOUND here.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/page-flags.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 19373c98d08a..be691551896b 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -288,7 +288,8 @@ PAGEFLAG(Pinned, pinned, NO_COMPOUND) TESTSCFLAG(Pinned, pinned, NO_COMPOUND)
 PAGEFLAG(SavePinned, savepinned, NO_COMPOUND)
 PAGEFLAG(Foreign, foreign, NO_COMPOUND)
 
-PAGEFLAG(Reserved, reserved, ANY) __CLEARPAGEFLAG(Reserved, reserved, ANY)
+PAGEFLAG(Reserved, reserved, NO_COMPOUND)
+	__CLEARPAGEFLAG(Reserved, reserved, NO_COMPOUND)
 PAGEFLAG(SwapBacked, swapbacked, ANY)
 	__CLEARPAGEFLAG(SwapBacked, swapbacked, ANY)
 	__SETPAGEFLAG(SwapBacked, swapbacked, ANY)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
