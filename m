Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id AB3F36B007E
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 10:54:27 -0500 (EST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH 6/6] staging: ramster: enable as staging driver
Date: Wed, 15 Feb 2012 07:54:20 -0800
Message-Id: <1329321260-15222-7-git-send-email-dan.magenheimer@oracle.com>
In-Reply-To: <1329321260-15222-1-git-send-email-dan.magenheimer@oracle.com>
References: <1329321260-15222-1-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, linux-mm@kvack.org, dan.magenheimer@oracle.com

RAMster implements peer-to-peer transcendent memory, allowing a "cluster"
of kernels to dynamically pool their RAM.

Enable build of ramster as a staging driver

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
---
 drivers/staging/Kconfig  |    2 ++
 drivers/staging/Makefile |    1 +
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/Kconfig b/drivers/staging/Kconfig
index b5a311b..c37dbc5 100644
--- a/drivers/staging/Kconfig
+++ b/drivers/staging/Kconfig
@@ -130,4 +130,6 @@ source "drivers/staging/android/Kconfig"
 
 source "drivers/staging/telephony/Kconfig"
 
+source "drivers/staging/ramster/Kconfig"
+
 endif # STAGING
diff --git a/drivers/staging/Makefile b/drivers/staging/Makefile
index 4908e46..035a035 100644
--- a/drivers/staging/Makefile
+++ b/drivers/staging/Makefile
@@ -55,3 +55,4 @@ obj-$(CONFIG_MFD_NVEC)		+= nvec/
 obj-$(CONFIG_DRM_OMAP)		+= omapdrm/
 obj-$(CONFIG_ANDROID)		+= android/
 obj-$(CONFIG_PHONE)		+= telephony/
+obj-$(CONFIG_RAMSTER)		+= ramster/
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
