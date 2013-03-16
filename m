Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 254DA6B0037
	for <linux-mm@kvack.org>; Sat, 16 Mar 2013 09:31:18 -0400 (EDT)
Received: by mail-ve0-f173.google.com with SMTP id oz10so3300241veb.4
        for <linux-mm@kvack.org>; Sat, 16 Mar 2013 06:31:17 -0700 (PDT)
From: Konrad Rzeszutek Wilk <konrad@kernel.org>
Subject: [PATCH] zcache/TODO: Update on two items.
Date: Sat, 16 Mar 2013 09:31:10 -0400
Message-Id: <1363440670-7262-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: konrad.wilk@oracle.com, gregkh@linuxfoundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: dan.magenheimer@oracle.com, sjenning@linux.vnet.ibm.com, minchan@kernel.org, liwanp@linux.vnet.ibm.com, bob.liu@oracle.com

Two of them (zcache DebugFS cleanup) and the module loading
capability are now in linux-next for v3.10.

Also Bob Liu is full-time going to help on knocking these items
off the list.

CC: bob.liu@oracle.com
Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 drivers/staging/zcache/TODO | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/drivers/staging/zcache/TODO b/drivers/staging/zcache/TODO
index c1e26d4..ec9aa11 100644
--- a/drivers/staging/zcache/TODO
+++ b/drivers/staging/zcache/TODO
@@ -41,14 +41,10 @@ STATUS/OWNERSHIP
     for 3.9, see https://lkml.org/lkml/2013/2/6/437;
 7. PROTOTYPED as part of "new" zcache; in staging/zcache for 3.9;
     needs more review (plan to discuss at LSF/MM 2013)
-8. IN PROGRESS; owned by Konrad Wilk; v2 recently posted
-   http://lkml.org/lkml/2013/2/1/542
 9. IN PROGRESS; owned by Konrad Wilk; Mel Gorman provided
    great feedback in August 2012 (unfortunately of "old"
    zcache)
-10. Konrad posted series of fixes (that now need rebasing)
-    https://lkml.org/lkml/2013/2/1/566 
-11. NOT DONE; owned by Konrad Wilk
+11. NOT DONE; owned by Konrad Wilk and Bob Liu
 12. TBD (depends on quantity of feedback)
 13. PROPOSED; one suggestion proposed by Dan; needs more ideas/feedback
 14. TBD (depends on feedback)
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
