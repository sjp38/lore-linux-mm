Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 4C8D06B005A
	for <linux-mm@kvack.org>; Sun, 23 Dec 2012 21:14:45 -0500 (EST)
Received: by mail-da0-f50.google.com with SMTP id h15so2937429dan.37
        for <linux-mm@kvack.org>; Sun, 23 Dec 2012 18:14:44 -0800 (PST)
From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH 06/29] mm/: rename random32() to prandom_u32()
Date: Mon, 24 Dec 2012 11:13:53 +0900
Message-Id: <1356315256-6572-7-git-send-email-akinobu.mita@gmail.com>
In-Reply-To: <1356315256-6572-1-git-send-email-akinobu.mita@gmail.com>
References: <1356315256-6572-1-git-send-email-akinobu.mita@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Cc: Akinobu Mita <akinobu.mita@gmail.com>, linux-mm@kvack.org

Use more preferable function name which implies using a pseudo-random
number generator.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: linux-mm@kvack.org
---
 mm/swapfile.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index e97a0e5..3af83bf 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2044,7 +2044,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	if (p->bdev) {
 		if (blk_queue_nonrot(bdev_get_queue(p->bdev))) {
 			p->flags |= SWP_SOLIDSTATE;
-			p->cluster_next = 1 + (random32() % p->highest_bit);
+			p->cluster_next = 1 + (prandom_u32() % p->highest_bit);
 		}
 		if ((swap_flags & SWAP_FLAG_DISCARD) && discard_swap(p) == 0)
 			p->flags |= SWP_DISCARDABLE;
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
