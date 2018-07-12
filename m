Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 323546B000C
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 19:36:48 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id v25-v6so11272766pfm.11
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 16:36:48 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id c15-v6si21063744pgw.550.2018.07.12.16.36.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 16:36:47 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH 1/6] swap: Add comments to lock_cluster_or_swap_info()
Date: Fri, 13 Jul 2018 07:36:31 +0800
Message-Id: <20180712233636.20629-2-ying.huang@intel.com>
In-Reply-To: <20180712233636.20629-1-ying.huang@intel.com>
References: <20180712233636.20629-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

From: Huang Ying <ying.huang@intel.com>

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
index d8fddfb000ec..e31aa601d9c0 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -297,6 +297,12 @@ static inline void unlock_cluster(struct swap_cluster_info *ci)
 		spin_unlock(&ci->lock);
 }
 
+/*
+ * At most times, fine grained cluster lock is sufficient to protect
+ * the operations on sis->swap_map.  No need to acquire gross grained
+ * sis->lock.  But cluster and cluster lock isn't available for HDD,
+ * so sis->lock will be instead for them.
+ */
 static inline struct swap_cluster_info *lock_cluster_or_swap_info(
 	struct swap_info_struct *si,
 	unsigned long offset)
-- 
2.16.4
