Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 174F76B0008
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 12:26:48 -0500 (EST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH 1/5] staging: ramster: disable build in anticipation of renaming
Date: Thu, 17 Jan 2013 09:26:33 -0800
Message-Id: <1358443597-9845-2-git-send-email-dan.magenheimer@oracle.com>
In-Reply-To: <1358443597-9845-1-git-send-email-dan.magenheimer@oracle.com>
References: <1358443597-9845-1-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, linux-mm@kvack.org, ngupta@vflare.org, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, minchan@kernel.org, dan.magenheimer@oracle.com

In staging, disable ramster build in anticipation of renaming to zcache

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
---
 drivers/staging/Kconfig  |    2 --
 drivers/staging/Makefile |    1 -
 2 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/Kconfig b/drivers/staging/Kconfig
index db8a512..eb61455 100644
--- a/drivers/staging/Kconfig
+++ b/drivers/staging/Kconfig
@@ -126,8 +126,6 @@ source "drivers/staging/csr/Kconfig"
 
 source "drivers/staging/omap-thermal/Kconfig"
 
-source "drivers/staging/ramster/Kconfig"
-
 source "drivers/staging/silicom/Kconfig"
 
 source "drivers/staging/ced1401/Kconfig"
diff --git a/drivers/staging/Makefile b/drivers/staging/Makefile
index a9d5479..18420b8 100644
--- a/drivers/staging/Makefile
+++ b/drivers/staging/Makefile
@@ -55,7 +55,6 @@ obj-$(CONFIG_USB_G_CCG)		+= ccg/
 obj-$(CONFIG_WIMAX_GDM72XX)	+= gdm72xx/
 obj-$(CONFIG_CSR_WIFI)		+= csr/
 obj-$(CONFIG_OMAP_BANDGAP)	+= omap-thermal/
-obj-$(CONFIG_ZCACHE2)		+= ramster/
 obj-$(CONFIG_NET_VENDOR_SILICOM)	+= silicom/
 obj-$(CONFIG_CED1401)		+= ced1401/
 obj-$(CONFIG_DRM_IMX)		+= imx-drm/
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
