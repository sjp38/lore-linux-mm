Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 183126B006C
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 13:28:04 -0500 (EST)
From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 265/493] mm/vmscan.c: remove use of __devinit
Date: Mon, 19 Nov 2012 13:23:34 -0500
Message-Id: <1353349642-3677-265-git-send-email-wfp5p@virginia.edu>
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org
Cc: linux-mm@kvack.org

CONFIG_HOTPLUG is going away as an option so __devinit is no longer
needed.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: linux-mm@kvack.org 
---
 mm/vmscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9ca84e2..2a6a9ae 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3117,7 +3117,7 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
    not required for correctness.  So if the last cpu in a node goes
    away, we get changed to run anywhere: as the first one comes back,
    restore their cpu bindings. */
-static int __devinit cpu_callback(struct notifier_block *nfb,
+static int cpu_callback(struct notifier_block *nfb,
 				  unsigned long action, void *hcpu)
 {
 	int nid;
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
