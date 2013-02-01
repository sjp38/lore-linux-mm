Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 7C38F6B0022
	for <linux-mm@kvack.org>; Fri,  1 Feb 2013 15:23:30 -0500 (EST)
Received: by mail-vb0-f46.google.com with SMTP id b13so2666393vby.5
        for <linux-mm@kvack.org>; Fri, 01 Feb 2013 12:23:29 -0800 (PST)
From: Konrad Rzeszutek Wilk <konrad@kernel.org>
Subject: [PATCH 08/15] xen/tmem: Remove the subsys call.
Date: Fri,  1 Feb 2013 15:22:57 -0500
Message-Id: <1359750184-23408-9-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1359750184-23408-1-git-send-email-konrad.wilk@oracle.com>
References: <1359750184-23408-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.magenheimer@oracle.com, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, ngupta@vflare.org, rcj@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

We get:
drivers/xen/xen-selfballoon.c:577:134: warning: initialization from incompatible pointer type [enabled by default]

We actually do not need this function to be called
before tmem is loaded. So lets remove the subsys_init.

If tmem is built in as a module this is still OK as
xen_selfballoon_init ends up being exported and can
be called by the tmem module.

Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 drivers/xen/xen-selfballoon.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/xen/xen-selfballoon.c b/drivers/xen/xen-selfballoon.c
index 6965e9b..f2ef569 100644
--- a/drivers/xen/xen-selfballoon.c
+++ b/drivers/xen/xen-selfballoon.c
@@ -572,7 +572,3 @@ int xen_selfballoon_init(bool use_selfballooning, bool use_frontswap_selfshrink)
 	return 0;
 }
 EXPORT_SYMBOL(xen_selfballoon_init);
-
-#ifndef CONFIG_XEN_TMEM_MODULE
-subsys_initcall(xen_selfballoon_init);
-#endif
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
