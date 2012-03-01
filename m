Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id A32746B00E9
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 04:32:53 -0500 (EST)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH 1/2] ksm: clean up page_trans_compound_anon_split
Date: Thu, 1 Mar 2012 17:32:53 +0800
Message-ID: <1330594374-13497-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hughd@google.com, rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, linux-mm@kvack.org, Bob Liu <lliubbo@gmail.com>

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/ksm.c |   12 ++----------
 1 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 1925ffb..8e10786 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -817,7 +817,7 @@ out:
 
 static int page_trans_compound_anon_split(struct page *page)
 {
-	int ret = 0;
+	int ret = 1;
 	struct page *transhuge_head = page_trans_compound_anon(page);
 	if (transhuge_head) {
 		/* Get the reference on the head to split it. */
@@ -828,16 +828,8 @@ static int page_trans_compound_anon_split(struct page *page)
 			 */
 			if (PageAnon(transhuge_head))
 				ret = split_huge_page(transhuge_head);
-			else
-				/*
-				 * Retry later if split_huge_page run
-				 * from under us.
-				 */
-				ret = 1;
 			put_page(transhuge_head);
-		} else
-			/* Retry later if split_huge_page run from under us. */
-			ret = 1;
+		}
 	}
 	return ret;
 }
-- 
1.7.0.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
