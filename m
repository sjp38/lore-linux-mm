Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 06E956B0278
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 03:27:45 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id r67-v6so3874979pfd.21
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 00:27:44 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id a3-v6si22556744pld.351.2018.10.10.00.27.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 00:27:43 -0700 (PDT)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH -V6 21/21] swap: Update help of CONFIG_THP_SWAP
Date: Wed, 10 Oct 2018 15:19:24 +0800
Message-Id: <20181010071924.18767-22-ying.huang@intel.com>
In-Reply-To: <20181010071924.18767-1-ying.huang@intel.com>
References: <20181010071924.18767-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>, Dan Williams <dan.j.williams@intel.com>

The help of CONFIG_THP_SWAP is updated to reflect the latest progress
of THP (Tranparent Huge Page) swap optimization.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Reviewed-by: Dan Williams <dan.j.williams@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 mm/Kconfig | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 44f7d72010fd..63caae29ae2b 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -419,8 +419,6 @@ config THP_SWAP
 	depends on TRANSPARENT_HUGEPAGE && ARCH_WANTS_THP_SWAP && SWAP
 	help
 	  Swap transparent huge pages in one piece, without splitting.
-	  XXX: For now, swap cluster backing transparent huge page
-	  will be split after swapout.
 
 	  For selection by architectures with reasonable THP sizes.
 
-- 
2.16.4
