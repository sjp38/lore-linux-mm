Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B75536B0069
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 12:55:39 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 5so1304133703pgj.6
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 09:55:39 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id m13si6442061pga.262.2017.01.11.09.55.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 09:55:38 -0800 (PST)
From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: [PATCH v5 1/9] mm/swap: Fix kernel message in swap_info_get()
Date: Wed, 11 Jan 2017 09:55:11 -0800
Message-Id: <9b5f8bd6266f9da978c373f2384c8044df5e262c.1484082593.git.tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1484082593.git.tim.c.chen@linux.intel.com>
References: <cover.1484082593.git.tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1484082593.git.tim.c.chen@linux.intel.com>
References: <cover.1484082593.git.tim.c.chen@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Jonathan Corbet <corbet@lwn.net>, Tim Chen <tim.c.chen@linux.intel.com>

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
index 1c6e032..19a7c1d 100644
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
