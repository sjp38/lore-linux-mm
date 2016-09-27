Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4D4E128024E
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 13:17:56 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id fi2so35198884pad.3
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 10:17:56 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id ce5si3493204pad.132.2016.09.27.10.17.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Sep 2016 10:17:55 -0700 (PDT)
Date: Tue, 27 Sep 2016 10:17:55 -0700
From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: [PATCH 1/8] mm/swap: Fix kernel message in swap_info_get()
Message-ID: <20160927171754.GA17824@linux.intel.com>
Reply-To: tim.c.chen@linux.intel.com
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

From: "Huang, Ying" <ying.huang@intel.com>

swap_info_get() is used not only in swap free code path but also in
page_swapcount(), etc.  So the original kernel message in
swap_info_get() is not correct now.  Fix it via replacing "swap_free" to
"swap_info_get" in the message.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
 mm/swapfile.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 8f1b97d..f23d243 100644
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
