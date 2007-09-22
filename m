Date: Sat, 22 Sep 2007 10:47:09 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 1/5] oom: prevent including sched.h in header file
Message-ID: <alpine.DEB.0.9999.0709212311130.13727@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, Christoph Lameter <clameter@sgi.com>, Alexey Dobriyan <adobriyan@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

It's not necessary to include all of linux/sched.h in linux/oom.h.
Instead, simply include prototypes for the relevant structs and include
linux/types.h for gfp_t.

Cc: Andrea Arcangeli <andrea@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/oom.h |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -1,8 +1,6 @@
 #ifndef __INCLUDE_LINUX_OOM_H
 #define __INCLUDE_LINUX_OOM_H
 
-#include <linux/sched.h>
-
 /* /proc/<pid>/oom_adj set to -17 protects from the oom-killer */
 #define OOM_DISABLE (-17)
 /* inclusive */
@@ -11,6 +9,11 @@
 
 #ifdef __KERNEL__
 
+#include <linux/types.h>
+
+struct zonelist;
+struct notifier_block;
+
 /*
  * Types of limitations to the nodes from which allocations may occur
  */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
