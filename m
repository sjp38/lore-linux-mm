Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id ABF7A6B0293
	for <linux-mm@kvack.org>; Thu,  2 May 2013 20:01:49 -0400 (EDT)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 2 May 2013 18:01:48 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 45D4D3E40039
	for <linux-mm@kvack.org>; Thu,  2 May 2013 18:01:14 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4301SFP109162
	for <linux-mm@kvack.org>; Thu, 2 May 2013 18:01:28 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4301RDS008230
	for <linux-mm@kvack.org>; Thu, 2 May 2013 18:01:27 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 15/31] drivers/base/memory.c: alphabetize headers.
Date: Thu,  2 May 2013 17:00:47 -0700
Message-Id: <1367539263-19999-16-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>

---
 drivers/base/memory.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 14f8a69..5247698 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -10,20 +10,20 @@
  * SPARSEMEM should be contained here, or in mm/memory_hotplug.c.
  */
 
-#include <linux/module.h>
-#include <linux/init.h>
-#include <linux/topology.h>
+#include <linux/atomic.h>
 #include <linux/capability.h>
 #include <linux/device.h>
-#include <linux/memory.h>
+#include <linux/init.h>
 #include <linux/kobject.h>
+#include <linux/memory.h>
 #include <linux/memory_hotplug.h>
 #include <linux/mm.h>
+#include <linux/module.h>
 #include <linux/mutex.h>
-#include <linux/stat.h>
 #include <linux/slab.h>
+#include <linux/stat.h>
+#include <linux/topology.h>
 
-#include <linux/atomic.h>
 #include <asm/uaccess.h>
 
 static DEFINE_MUTEX(mem_sysfs_mutex);
-- 
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
