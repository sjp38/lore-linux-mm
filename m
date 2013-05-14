Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 30F9F6B0037
	for <linux-mm@kvack.org>; Tue, 14 May 2013 14:20:46 -0400 (EDT)
Received: by mail-vc0-f180.google.com with SMTP id gd11so920194vcb.25
        for <linux-mm@kvack.org>; Tue, 14 May 2013 11:20:45 -0700 (PDT)
From: Konrad Rzeszutek Wilk <konrad@kernel.org>
Subject: [PATCH 1/9] xen/tmem: Cleanup. Remove the parts that say temporary.
Date: Tue, 14 May 2013 14:09:18 -0400
Message-Id: <1368554966-30469-2-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1368554966-30469-1-git-send-email-konrad.wilk@oracle.com>
References: <1368554966-30469-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bob.liu@oracle.com, dan.magenheimer@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, xen-devel@lists.xensource.com
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

Frontswap is upstream, not of having this #ifdef.

Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 drivers/xen/tmem.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/xen/tmem.c b/drivers/xen/tmem.c
index e3600be..5686d6d 100644
--- a/drivers/xen/tmem.c
+++ b/drivers/xen/tmem.c
@@ -11,11 +11,7 @@
 #include <linux/init.h>
 #include <linux/pagemap.h>
 #include <linux/cleancache.h>
-
-/* temporary ifdef until include/linux/frontswap.h is upstream */
-#ifdef CONFIG_FRONTSWAP
 #include <linux/frontswap.h>
-#endif
 
 #include <xen/xen.h>
 #include <xen/interface/xen.h>
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
