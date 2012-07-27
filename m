Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 94D746B0068
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 14:19:39 -0400 (EDT)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Fri, 27 Jul 2012 12:19:37 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 3921519D803C
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 18:18:59 +0000 (WET)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6RIIpES258078
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 12:18:55 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6RIIogR010266
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 12:18:50 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH 3/4] drivers: add memory management driver class
Date: Fri, 27 Jul 2012 13:18:36 -0500
Message-Id: <1343413117-1989-4-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

This patchset creates a new driver class under drivers/ for
memory management related drivers, like zcache.

This driver class would be for drivers that don't actually enabled
a hardware device, but rather augment the memory manager in some
way.

In-tree candidates for this driver class are zcache, zram, and
lowmemorykiller, both in staging.

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 drivers/Kconfig    |    2 ++
 drivers/Makefile   |    1 +
 drivers/mm/Kconfig |    3 +++
 3 files changed, 6 insertions(+)
 create mode 100644 drivers/mm/Kconfig

diff --git a/drivers/Kconfig b/drivers/Kconfig
index ece958d..67fe7bd 100644
--- a/drivers/Kconfig
+++ b/drivers/Kconfig
@@ -152,4 +152,6 @@ source "drivers/vme/Kconfig"
 
 source "drivers/pwm/Kconfig"
 
+source "drivers/mm/Kconfig"
+
 endmenu
diff --git a/drivers/Makefile b/drivers/Makefile
index 5b42184..121742e 100644
--- a/drivers/Makefile
+++ b/drivers/Makefile
@@ -139,3 +139,4 @@ obj-$(CONFIG_EXTCON)		+= extcon/
 obj-$(CONFIG_MEMORY)		+= memory/
 obj-$(CONFIG_IIO)		+= iio/
 obj-$(CONFIG_VME_BUS)		+= vme/
+obj-$(CONFIG_MM_DRIVERS)	+= mm/
diff --git a/drivers/mm/Kconfig b/drivers/mm/Kconfig
new file mode 100644
index 0000000..e5b3743
--- /dev/null
+++ b/drivers/mm/Kconfig
@@ -0,0 +1,3 @@
+menu "Memory management drivers"
+
+endmenu
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
