Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8FA596B0008
	for <linux-mm@kvack.org>; Wed, 23 May 2018 04:26:38 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b25-v6so12687188pfn.10
        for <linux-mm@kvack.org>; Wed, 23 May 2018 01:26:38 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id 3-v6si19009042plf.84.2018.05.23.01.26.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 May 2018 01:26:37 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -V3 02/21] mm, THP, swap: Make CONFIG_THP_SWAP depends on CONFIG_SWAP
Date: Wed, 23 May 2018 16:26:06 +0800
Message-Id: <20180523082625.6897-3-ying.huang@intel.com>
In-Reply-To: <20180523082625.6897-1-ying.huang@intel.com>
References: <20180523082625.6897-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

From: Huang Ying <ying.huang@intel.com>

It's unreasonable to optimize swapping for THP without basic swapping
support.  And this will cause build errors when THP_SWAP functions are
defined in swapfile.c and called elsewhere.

The comments are fixed too to reflect the latest progress.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
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
---
 mm/Kconfig | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index ce95491abd6a..cee958bb6002 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -420,10 +420,9 @@ config ARCH_WANTS_THP_SWAP
 
 config THP_SWAP
 	def_bool y
-	depends on TRANSPARENT_HUGEPAGE && ARCH_WANTS_THP_SWAP
+	depends on TRANSPARENT_HUGEPAGE && ARCH_WANTS_THP_SWAP && SWAP
 	help
 	  Swap transparent huge pages in one piece, without splitting.
-	  XXX: For now this only does clustered swap space allocation.
 
 	  For selection by architectures with reasonable THP sizes.
 
-- 
2.16.1
