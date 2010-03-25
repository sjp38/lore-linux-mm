Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D726A6B01AE
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 18:53:20 -0400 (EDT)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id o2PMrHAq032563
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 15:53:18 -0700
Received: from pzk29 (pzk29.prod.google.com [10.243.19.157])
	by kpbe20.cbf.corp.google.com with ESMTP id o2PMqe8S012371
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 15:53:16 -0700
Received: by pzk29 with SMTP id 29so1489783pzk.27
        for <linux-mm@kvack.org>; Thu, 25 Mar 2010 15:53:16 -0700 (PDT)
Date: Thu, 25 Mar 2010 15:53:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm] oom: move sysctl declarations to oom.h
Message-ID: <alpine.DEB.2.00.1003251552350.18932@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The three oom killer sysctl variables (sysctl_panic_on_oom,
sysctl_oom_forkbomb_thres, and sysctl_oom_kill_quick) are better declared
in include/linux/oom.h rather than kernel/sysctl.c.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/oom.h |    6 ++++++
 kernel/sysctl.c     |    4 +---
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -61,5 +61,11 @@ static inline void oom_killer_enable(void)
 {
 	oom_killer_disabled = false;
 }
+
+/* sysctls */
+extern int sysctl_panic_on_oom;
+extern int sysctl_oom_forkbomb_thres;
+extern int sysctl_oom_kill_quick;
+
 #endif /* __KERNEL__*/
 #endif /* _INCLUDE_LINUX_OOM_H */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -53,6 +53,7 @@
 #include <linux/slow-work.h>
 #include <linux/perf_event.h>
 #include <linux/kprobes.h>
+#include <linux/oom.h>
 
 #include <asm/uaccess.h>
 #include <asm/processor.h>
@@ -81,9 +82,6 @@
 /* External variables not in a header file. */
 extern int sysctl_overcommit_memory;
 extern int sysctl_overcommit_ratio;
-extern int sysctl_panic_on_oom;
-extern int sysctl_oom_kill_quick;
-extern int sysctl_oom_forkbomb_thres;
 extern int max_threads;
 extern int core_uses_pid;
 extern int suid_dumpable;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
