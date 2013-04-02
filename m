Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 482DF6B0002
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 07:10:25 -0400 (EDT)
Message-ID: <515ABC79.5060900@huawei.com>
Date: Tue, 2 Apr 2013 19:09:45 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm/vmscan: fix error return in kswapd_run()
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, hughd@google.com, riel@redhat.com, khlebnikov@openvz.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Xishi Qiu <qiuxishi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Zhangdianfang <zhangdianfang@huawei.com>

Fix the error return value in kswapd_run(). The bug was
introduced by commit d5dc0ad928fb9e972001e552597fd0b794863f34
"mm/vmscan: fix error number for failed kthread".

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/vmscan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 88c5fed..950636e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3188,9 +3188,9 @@ int kswapd_run(int nid)
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
1.7.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
