Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id CA2B86B00B3
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 13:57:37 -0500 (EST)
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: [PATCH 8/8] xen/tmem: Remove the subsys call.
Date: Wed, 14 Nov 2012 13:57:12 -0500
Message-Id: <1352919432-9699-9-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1352919432-9699-1-git-send-email-konrad.wilk@oracle.com>
References: <1352919432-9699-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sjenning@linux.vnet.ibm.com, dan.magenheimer@oracle.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, minchan@kernel.org, akpm@linux-foundation.org, mgorman@suse.de
Cc: fschmaus@gmail.com, andor.daam@googlemail.com, ilendir@googlemail.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

We get:
drivers/xen/xen-selfballoon.c:577:134: warning: initialization from incompatible pointer type [enabled by default]

We actually do not need this function to be called
before tmem is loaded. So lets remove the subsys_init.

If tmem is built in as a module this is still OK as
xen_selfballoon_init ends up being exported and can
be called by the tmem module.

Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 drivers/xen/xen-selfballoon.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/xen/xen-selfballoon.c b/drivers/xen/xen-selfballoon.c
index f4808aa..0bd551e 100644
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
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
