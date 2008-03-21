Subject: [PATCH] Add definitions of USHRT_MAX
From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Date: Fri, 21 Mar 2008 09:40:14 +0800
Message-Id: <1206063614.14496.72.camel@ymzhang>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Add definitions of USHRT_MAX and others into kernel. ipc uses it and
slub implementation might also use it.

The patch is against 2.6.25-rc6.

Signed-off-by: Zhang Yanmin <yanmin.zhang@intel.com>
Reviewed-by: Christoph Lameter <clameter@sgi.com>

---

--- linux-2.6.25-rc6/include/linux/kernel.h	2008-03-20 04:25:46.000000000 +0800
+++ linux-2.6.25-rc6_work/include/linux/kernel.h	2008-03-20 04:17:45.000000000 +0800
@@ -20,6 +20,9 @@
 extern const char linux_banner[];
 extern const char linux_proc_banner[];
 
+#define USHRT_MAX	((u16)(~0U))
+#define SHRT_MAX	((s16)(USHRT_MAX>>1))
+#define SHRT_MIN	(-SHRT_MAX - 1)
 #define INT_MAX		((int)(~0U>>1))
 #define INT_MIN		(-INT_MAX - 1)
 #define UINT_MAX	(~0U)
--- linux-2.6.25-rc6/ipc/util.h	2008-03-20 04:25:46.000000000 +0800
+++ linux-2.6.25-rc6_work/ipc/util.h	2008-03-20 04:22:07.000000000 +0800
@@ -12,7 +12,6 @@
 
 #include <linux/err.h>
 
-#define USHRT_MAX 0xffff
 #define SEQ_MULTIPLIER	(IPCMNI)
 
 void sem_init (void);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
