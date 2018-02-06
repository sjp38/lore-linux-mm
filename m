Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id EF1166B02A2
	for <linux-mm@kvack.org>; Tue,  6 Feb 2018 16:58:44 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id g16so1540053wmg.6
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 13:58:44 -0800 (PST)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id 200si255310wme.70.2018.02.06.13.58.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Feb 2018 13:58:43 -0800 (PST)
From: Colin King <colin.king@canonical.com>
Subject: [PATCH] mm: swap: make pointer swap_avail_heads static
Date: Tue,  6 Feb 2018 21:58:36 +0000
Message-Id: <20180206215836.12366-1-colin.king@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, linux-mm@kvack.org
Cc: kernel-janitors@vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The pointer swap_avail_heads is local to the source and does not need
to be in global scope, so make it static.

Cleans up sparse warning:
mm/swapfile.c:88:19: warning: symbol 'swap_avail_heads' was not
declared. Should it be static?

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 mm/swapfile.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 006047b16814..0d00471af98b 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -85,7 +85,7 @@ PLIST_HEAD(swap_active_head);
  * is held and the locking order requires swap_lock to be taken
  * before any swap_info_struct->lock.
  */
-struct plist_head *swap_avail_heads;
+static struct plist_head *swap_avail_heads;
 static DEFINE_SPINLOCK(swap_avail_lock);
 
 struct swap_info_struct *swap_info[MAX_SWAPFILES];
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
