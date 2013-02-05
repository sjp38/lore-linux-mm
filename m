Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 00AC36B0007
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 18:17:16 -0500 (EST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] mm: Get rid of lockdep whinge on sys_swapon
Date: Wed,  6 Feb 2013 08:17:12 +0900
Message-Id: <1360106232-15501-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@kernel.org>

[1] forgot to initialize spin_lock so lockdep is whingeing
about it. This patch fixes it.

[1] 0f181e0e4, swap: add per-partition lock for swapfile

Cc: Shaohua Li <shli@kernel.org>
Reported/Tested-by: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/swapfile.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index dfaff5f..ac190d6 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1857,6 +1857,7 @@ static struct swap_info_struct *alloc_swap_info(void)
 	p->flags = SWP_USED;
 	p->next = -1;
 	spin_unlock(&swap_lock);
+	spin_lock_init(&p->lock);
 
 	return p;
 }
-- 
1.8.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
