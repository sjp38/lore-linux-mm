Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id CB2EA6B00ED
	for <linux-mm@kvack.org>; Thu,  3 May 2012 10:24:07 -0400 (EDT)
From: Venkatraman S <svenkatr@ti.com>
Subject: [PATCH v2 05/16] block: Documentation: add sysfs ABI for expedite_dmpg and expedite_swapin
Date: Thu, 3 May 2012 19:53:04 +0530
Message-ID: <1336054995-22988-6-git-send-email-svenkatr@ti.com>
In-Reply-To: <1336054995-22988-1-git-send-email-svenkatr@ti.com>
References: <1336054995-22988-1-git-send-email-svenkatr@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mmc@vger.kernel.org, cjb@laptop.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-omap@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, arnd.bergmann@linaro.org, alex.lemberg@sandisk.com, ilan.smith@sandisk.com, lporzio@micron.com, rmk+kernel@arm.linux.org.uk, Venkatraman S <svenkatr@ti.com>

Add description on the usage of expedite_dmpg and
expedite_swapin.

Signed-off-by: Venkatraman S <svenkatr@ti.com>
---
 Documentation/ABI/testing/sysfs-block |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/Documentation/ABI/testing/sysfs-block b/Documentation/ABI/testing/sysfs-block
index c1eb41c..0fb9fef 100644
--- a/Documentation/ABI/testing/sysfs-block
+++ b/Documentation/ABI/testing/sysfs-block
@@ -206,3 +206,15 @@ Description:
 		when a discarded area is read the discard_zeroes_data
 		parameter will be set to one. Otherwise it will be 0 and
 		the result of reading a discarded area is undefined.
+
+What:		/sys/block/<disk>/queue/expedite_demandpaging
+What:		/sys/block/<disk>/queue/expedite_swapin
+Date:		April 2012
+Contact:	Venkatraman S <svenkatr@ti.com>
+Description:
+		For latency improvements, some storage devices could
+		provide a mechanism for servicing demand paging and
+		swapin requests in a high priority manner. Setting
+		these flags to 1 would get the requests marked with
+		REQ_RW_DMPG or REQ_RW_SWAPIN to be moved to the front
+		of elevator queue.
-- 
1.7.10.rc2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
