Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8D8666B66CF
	for <linux-mm@kvack.org>; Mon,  3 Sep 2018 03:23:17 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id o16-v6so10228543pgv.21
        for <linux-mm@kvack.org>; Mon, 03 Sep 2018 00:23:17 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id az1-v6si9327648plb.513.2018.09.03.00.23.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Sep 2018 00:23:16 -0700 (PDT)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH -V5 21/21] swap: Update help of CONFIG_THP_SWAP
Date: Mon,  3 Sep 2018 15:22:14 +0800
Message-Id: <20180903072214.24602-22-ying.huang@intel.com>
In-Reply-To: <20180903072214.24602-1-ying.huang@intel.com>
References: <20180903072214.24602-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>, Dan Williams <dan.j.williams@intel.com>

The help of CONFIG_THP_SWAP is updated to reflect the latest progress
of THP (Tranparent Huge Page) swap optimization.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Reviewed-by: Dan Williams <dan.j.williams@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
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
index 0163ff069fd1..8dac2fb19203 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -425,8 +425,6 @@ config THP_SWAP
 	depends on TRANSPARENT_HUGEPAGE && ARCH_WANTS_THP_SWAP && SWAP
 	help
 	  Swap transparent huge pages in one piece, without splitting.
-	  XXX: For now, swap cluster backing transparent huge page
-	  will be split after swapout.
 
 	  For selection by architectures with reasonable THP sizes.
 
-- 
2.16.4
