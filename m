Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 3E3DF6B0007
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 12:26:47 -0500 (EST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH 4/5] staging: zcache: re-enable config/build of zcache after renaming
Date: Thu, 17 Jan 2013 09:26:36 -0800
Message-Id: <1358443597-9845-5-git-send-email-dan.magenheimer@oracle.com>
In-Reply-To: <1358443597-9845-1-git-send-email-dan.magenheimer@oracle.com>
References: <1358443597-9845-1-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, linux-mm@kvack.org, ngupta@vflare.org, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, minchan@kernel.org, dan.magenheimer@oracle.com

In staging, re-enable config/build of zcache after ramster->zcache renaming.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
---
 drivers/staging/Kconfig  |    2 ++
 drivers/staging/Makefile |    1 +
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/Kconfig b/drivers/staging/Kconfig
index eb61455..0b47a06 100644
--- a/drivers/staging/Kconfig
+++ b/drivers/staging/Kconfig
@@ -138,4 +138,6 @@ source "drivers/staging/sb105x/Kconfig"
 
 source "drivers/staging/fwserial/Kconfig"
 
+source "drivers/staging/zcache/Kconfig"
+
 endif # STAGING
diff --git a/drivers/staging/Makefile b/drivers/staging/Makefile
index 18420b8..b026ea3 100644
--- a/drivers/staging/Makefile
+++ b/drivers/staging/Makefile
@@ -61,3 +61,4 @@ obj-$(CONFIG_DRM_IMX)		+= imx-drm/
 obj-$(CONFIG_DGRP)		+= dgrp/
 obj-$(CONFIG_SB105X)		+= sb105x/
 obj-$(CONFIG_FIREWIRE_SERIAL)	+= fwserial/
+obj-$(CONFIG_ZCACHE)		+= zcache/
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
