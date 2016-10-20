Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 22C2A6B0260
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 19:32:15 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id u84so37776894pfj.6
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 16:32:15 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id f17si3443177pgh.236.2016.10.20.16.32.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Oct 2016 16:32:14 -0700 (PDT)
From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: [PATCH v2 1/8] mm/swap: Fix kernel message in swap_info_get()
Date: Thu, 20 Oct 2016 16:31:40 -0700
Message-Id: <b0e165c81fa73a515f2aa01bfb4c693636360da6.1477004978.git.tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1477004978.git.tim.c.chen@linux.intel.com>
References: <cover.1477004978.git.tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1477004978.git.tim.c.chen@linux.intel.com>
References: <cover.1477004978.git.tim.c.chen@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Tim Chen <tim.c.chen@linux.intel.com>

From: "Huang, Ying" <ying.huang@intel.com>

swap_info_get() is used not only in swap free code path but also in
page_swapcount(), etc.  So the original kernel message in
swap_info_get() is not correct now.  Fix it via replacing "swap_free" to
"swap_info_get" in the message.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 mm/swapfile.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 2210de2..b745d3d 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -753,16 +753,16 @@ static struct swap_info_struct *swap_info_get(swp_entry_t entry)
 	return p;
 
 bad_free:
-	pr_err("swap_free: %s%08lx\n", Unused_offset, entry.val);
+	pr_err("swap_info_get: %s%08lx\n", Unused_offset, entry.val);
 	goto out;
 bad_offset:
-	pr_err("swap_free: %s%08lx\n", Bad_offset, entry.val);
+	pr_err("swap_info_get: %s%08lx\n", Bad_offset, entry.val);
 	goto out;
 bad_device:
-	pr_err("swap_free: %s%08lx\n", Unused_file, entry.val);
+	pr_err("swap_info_get: %s%08lx\n", Unused_file, entry.val);
 	goto out;
 bad_nofile:
-	pr_err("swap_free: %s%08lx\n", Bad_file, entry.val);
+	pr_err("swap_info_get: %s%08lx\n", Bad_file, entry.val);
 out:
 	return NULL;
 }
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
