Date: Tue, 15 Jul 2008 01:20:38 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [mmotm] fix build error caused by !NUMA migration
Message-Id: <20080715011230.F6EB.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Patch title: mm-make-config_migration-available-w-o-config_numa-fix.patch
Against: mmotm Jul 14
Applies after: mm-make-config_migration-available-w-o-config_numa.patch

"Make CONFIG_MIGRATION available w/o CONFIG_NUMA" patch add pagemap.h inclusion.

Unfortunately, mempolicy.h is userland exported header, but pagemap.h isn't.
then it cause build error on IA64 && CONFIG_DISCONTIGMEM environment.


    CHECK   include/linux (342 files)
      linux-2.6.26-rc9-mmotm-0714/usr/include/linux/mempolicy.h:5: included file 'linux/pagemap.h' is not exported
      make[3]: *** [linux-2.6.26-rc9-mmotm-0714/usr/include/linux/.check] Error 1



Signed-off-by: KOSAKI Motorhiro <kosaki.motohiro@jp.fujitsu.com>
CC: Christoph Lameter <cl@linux-foundation.org>
CC: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>

---
 include/linux/mempolicy.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: b/include/linux/mempolicy.h
===================================================================
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -2,7 +2,6 @@
 #define _LINUX_MEMPOLICY_H 1
 
 #include <linux/errno.h>
-#include <linux/pagemap.h>
 
 /*
  * NUMA memory policies for Linux.
@@ -60,6 +59,7 @@ enum {
 #include <linux/rbtree.h>
 #include <linux/spinlock.h>
 #include <linux/nodemask.h>
+#include <linux/pagemap.h>
 
 struct mm_struct;
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
