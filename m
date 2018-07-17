Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id A6FB46B0266
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 20:55:50 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id t5-v6so4162698pgt.18
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 17:55:50 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id bc5-v6si30619643plb.413.2018.07.16.17.55.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 17:55:49 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH v2 1/7] swap: Add comments to lock_cluster_or_swap_info()
Date: Tue, 17 Jul 2018 08:55:50 +0800
Message-Id: <20180717005556.29758-2-ying.huang@intel.com>
In-Reply-To: <20180717005556.29758-1-ying.huang@intel.com>
References: <20180717005556.29758-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

To improve the code readability.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Suggested-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Dan Williams <dan.j.williams@intel.com>
---
 mm/swapfile.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index d8fddfb000ec..0a2a9643dd78 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -297,6 +297,12 @@ static inline void unlock_cluster(struct swap_cluster_info *ci)
 		spin_unlock(&ci->lock);
 }
 
+/*
+ * For non-HDD swap devices, the fine grained cluster lock is used to
+ * protect si->swap_map.  But cluster and cluster locks isn't
+ * available for HDD, so coarse grained si->lock will be used instead
+ * for that.
+ */
 static inline struct swap_cluster_info *lock_cluster_or_swap_info(
 	struct swap_info_struct *si,
 	unsigned long offset)
-- 
2.16.4
