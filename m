Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 02F5B6B0062
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 03:50:50 -0400 (EDT)
Message-ID: <509229D3.5020208@oracle.com>
Date: Thu, 01 Nov 2012 15:50:43 +0800
From: Jeff Liu <jeff.liu@oracle.com>
MIME-Version: 1.0
Subject: [PATCH] mm/vmscan.c: s/int ret/bool ret/ in kswapd() because try_to_freeze()
 return boolean
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

Hello,

kswapd()->try_to_freeze() is defined to return a boolean, so it's better
to fix the return value type accordingly.

Thanks,
-Jeff

Signed-off-by: Jie Liu <jeff.liu@oracle.com>

---
 mm/vmscan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2624edc..49e4c6a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2969,7 +2969,7 @@ static int kswapd(void *p)
 	classzone_idx = new_classzone_idx = pgdat->nr_zones - 1;
 	balanced_classzone_idx = classzone_idx;
 	for ( ; ; ) {
-		int ret;
+		bool ret;
 
 		/*
 		 * If the last balance_pgdat was unsuccessful it's unlikely a
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
