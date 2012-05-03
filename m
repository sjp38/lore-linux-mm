Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 1CE8A6B00F3
	for <linux-mm@kvack.org>; Thu,  3 May 2012 10:24:45 -0400 (EDT)
From: Venkatraman S <svenkatr@ti.com>
Subject: [PATCH v2 13/16] mmc: Documentation: Add sysfs ABI for hpi_time_threshold
Date: Thu, 3 May 2012 19:53:12 +0530
Message-ID: <1336054995-22988-14-git-send-email-svenkatr@ti.com>
In-Reply-To: <1336054995-22988-1-git-send-email-svenkatr@ti.com>
References: <1336054995-22988-1-git-send-email-svenkatr@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mmc@vger.kernel.org, cjb@laptop.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-omap@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, arnd.bergmann@linaro.org, alex.lemberg@sandisk.com, ilan.smith@sandisk.com, lporzio@micron.com, rmk+kernel@arm.linux.org.uk, Venkatraman S <svenkatr@ti.com>

hpi_time_threshold can be set to configure elapsed time in ms,
after which an ongoing request will not be preempted.
Explain the hpi_time_threhold parameter for MMC devices.

Signed-off-by: Venkatraman S <svenkatr@ti.com>
---
 Documentation/ABI/testing/sysfs-devices-mmc |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/Documentation/ABI/testing/sysfs-devices-mmc b/Documentation/ABI/testing/sysfs-devices-mmc
index 5a50ab6..133dba5 100644
--- a/Documentation/ABI/testing/sysfs-devices-mmc
+++ b/Documentation/ABI/testing/sysfs-devices-mmc
@@ -19,3 +19,15 @@ Description:
 		is enabled, this attribute will indicate the size of enhanced
 		data area. If not, this attribute will be -EINVAL.
 		Unit KByte. Format decimal.
+
+What:		/sys/devices/.../mmc_host/mmcX/mmcX:XXXX/hpi_time_threshold
+Date:		April 2012
+Contact:	Venkatraman S <svenkatr@ti.com>
+Description:
+		High Priority Interrupt is a new feature defined in eMMC4.4
+		standard. If this feature is enabled, stack needs to decide
+		till what time since the last issued request is considered
+		preemptible. This attribute value (in milliseconds) is
+		used for arriving at the most optimal value for a specific
+		card. Default is zero, which also disables the feature, as
+		the request becomes non-preemptible immediately.
-- 
1.7.10.rc2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
