Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2378B6B0272
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 04:48:54 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id k9-v6so3749323pff.5
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 01:48:54 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id x18-v6si4948122pll.193.2018.07.19.01.48.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 01:48:53 -0700 (PDT)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH v3 1/8] swap: Add comments to lock_cluster_or_swap_info()
Date: Thu, 19 Jul 2018 16:48:35 +0800
Message-Id: <20180719084842.11385-2-ying.huang@intel.com>
In-Reply-To: <20180719084842.11385-1-ying.huang@intel.com>
References: <20180719084842.11385-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Daniel Jordan <daniel.m.jordan@oracle.com>

To improve the code readability.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Suggested-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>
---
 mm/swapfile.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index d8fddfb000ec..29da44411734 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -297,13 +297,19 @@ static inline void unlock_cluster(struct swap_cluster_info *ci)
 		spin_unlock(&ci->lock);
 }
 
+/*
+ * Determine the locking method in use for this device.  Return
+ * swap_cluster_info if SSD-style cluster-based locking is in place.
+ */
 static inline struct swap_cluster_info *lock_cluster_or_swap_info(
 	struct swap_info_struct *si,
 	unsigned long offset)
 {
 	struct swap_cluster_info *ci;
 
+	/* Try to use fine-grained SSD-style locking if available: */
 	ci = lock_cluster(si, offset);
+	/* Otherwise, fall back to traditional, coarse locking: */
 	if (!ci)
 		spin_lock(&si->lock);
 
-- 
2.16.4
