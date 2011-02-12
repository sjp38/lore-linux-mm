Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5A0158D0039
	for <linux-mm@kvack.org>; Fri, 11 Feb 2011 23:14:10 -0500 (EST)
Received: by qwa26 with SMTP id 26so1998875qwa.14
        for <linux-mm@kvack.org>; Fri, 11 Feb 2011 20:14:07 -0800 (PST)
From: Nitin Gupta <ngupta@vflare.org>
Subject: [PATCH] zcache: Fix build error when sysfs is not defined
Date: Fri, 11 Feb 2011 23:14:39 -0500
Message-Id: <1297484079-12562-1-git-send-email-ngupta@vflare.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Randy Dunlap <randy.dunlap@oracle.com>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

Signed-off-by: Nitin Gupta <ngupta@vflare.org>
---
 drivers/staging/zcache/zcache.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/zcache/zcache.c b/drivers/staging/zcache/zcache.c
index 61be849..8cd3fd8 100644
--- a/drivers/staging/zcache/zcache.c
+++ b/drivers/staging/zcache/zcache.c
@@ -1590,9 +1590,9 @@ __setup("nofrontswap", no_frontswap);
 
 static int __init zcache_init(void)
 {
-#ifdef CONFIG_SYSFS
 	int ret = 0;
 
+#ifdef CONFIG_SYSFS
 	ret = sysfs_create_group(mm_kobj, &zcache_attr_group);
 	if (ret) {
 		pr_err("zcache: can't create sysfs\n");
-- 
1.7.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
