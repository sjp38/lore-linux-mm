Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 89A726B0068
	for <linux-mm@kvack.org>; Thu,  3 Jan 2013 07:19:51 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id fb10so8581853pad.2
        for <linux-mm@kvack.org>; Thu, 03 Jan 2013 04:19:50 -0800 (PST)
From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH -v2 06/26] mm/: rename random32() to prandom_u32()
Date: Thu,  3 Jan 2013 21:19:02 +0900
Message-Id: <1357215562-6288-7-git-send-email-akinobu.mita@gmail.com>
In-Reply-To: <1357215562-6288-1-git-send-email-akinobu.mita@gmail.com>
References: <1357215562-6288-1-git-send-email-akinobu.mita@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Cc: Akinobu Mita <akinobu.mita@gmail.com>, linux-mm@kvack.org

Use more preferable function name which implies using a pseudo-random
number generator.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: linux-mm@kvack.org
---

No change from v1

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
