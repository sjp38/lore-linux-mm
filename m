Date: Mon, 14 Jul 2008 19:56:23 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [mmotm] mm-create-sys-kernel-mm fix
Message-Id: <20080714195446.F6DC.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Patch title: mm-create-sys-kernel-mm-fix.patch
Against: mmotm Jul 13
Applies after: mm-create-sys-kernel-mm.patch

Recently, Nishanth Aravamudan introduce /sys/kernel/mm and
add EXPORT_SYMBOL_GPL() to mm_init.c.
then module.h should be included.

otherwise following warning happend.

  mm/mm_init.c:140: warning: data definition has no type or storage class
  mm/mm_init.c:140: warning: type defaults to 'int' in declaration of 'EXPORT_SYMBOL_GPL'
  mm/mm_init.c:140: warning: parameter names (without types) in function declaration

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Mel Gorman <mel@csn.ul.ie>

---
 mm/mm_init.c |    1 +
 1 file changed, 1 insertion(+)

Index: b/mm/mm_init.c
===================================================================
--- a/mm/mm_init.c
+++ b/mm/mm_init.c
@@ -8,6 +8,7 @@
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/kobject.h>
+#include <linux/module.h>
 #include "internal.h"
 
 #ifdef CONFIG_DEBUG_MEMORY_INIT


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
