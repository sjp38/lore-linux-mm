Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9B95C6B1F5B
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 03:56:10 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id w19-v6so963252plq.1
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 00:56:10 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id c14si6866550pgw.151.2018.11.20.00.56.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 00:56:09 -0800 (PST)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH -V7 RESEND 21/21] swap: Update help of CONFIG_THP_SWAP
Date: Tue, 20 Nov 2018 16:54:49 +0800
Message-Id: <20181120085449.5542-22-ying.huang@intel.com>
In-Reply-To: <20181120085449.5542-1-ying.huang@intel.com>
References: <20181120085449.5542-1-ying.huang@intel.com>
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
index d7c5299c5b7d..d397baa92a9b 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -417,8 +417,6 @@ config THP_SWAP
 	depends on TRANSPARENT_HUGEPAGE && ARCH_WANTS_THP_SWAP && SWAP
 	help
 	  Swap transparent huge pages in one piece, without splitting.
-	  XXX: For now, swap cluster backing transparent huge page
-	  will be split after swapout.
 
 	  For selection by architectures with reasonable THP sizes.
 
-- 
2.18.1
