Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 824796B00B7
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 10:53:22 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id r11so2276606pdi.35
        for <linux-mm@kvack.org>; Fri, 19 Apr 2013 07:53:21 -0700 (PDT)
From: Jonghwan Choi <jhbird.choi@gmail.com>
Subject: [RESEND PATCH 3.8-stable] mm/vmscan: fix error return in kswapd_run()
Date: Fri, 19 Apr 2013 23:52:10 +0900
Message-Id: <1366383130-2500-1-git-send-email-jhbird.choi@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>, Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: stable@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Jonghwan Choi <jhbird.choi@samsung.com>

From: Gavin Shan <shangw@linux.vnet.ibm.com>

This patch looks like it should be in the 3.8-stable tree, should we apply
it?

------------------

From: "Gavin Shan <shangw@linux.vnet.ibm.com>"

commit d5dc0ad928fb9e972001e552597fd0b794863f34 upstream

Fix the error return value in kswapd_run().  The bug was introduced by
commit d5dc0ad928fb ("mm/vmscan: fix error number for failed kthread").

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
Reported-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Jonghwan Choi <jhbird.choi@samsung.com>
---
 mm/vmscan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 196709f..8226b41 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3158,9 +3158,9 @@ int kswapd_run(int nid)
 	if (IS_ERR(pgdat->kswapd)) {
 		/* failure at boot is fatal */
 		BUG_ON(system_state == SYSTEM_BOOTING);
-		pgdat->kswapd = NULL;
 		pr_err("Failed to start kswapd on node %d\n", nid);
 		ret = PTR_ERR(pgdat->kswapd);
+		pgdat->kswapd = NULL;
 	}
 	return ret;
 }
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
