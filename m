Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C3F516B01D0
	for <linux-mm@kvack.org>; Sun,  6 Jun 2010 18:34:52 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id o56MYqOF023856
	for <linux-mm@kvack.org>; Sun, 6 Jun 2010 15:34:52 -0700
Received: from pwj8 (pwj8.prod.google.com [10.241.219.72])
	by wpaz33.hot.corp.google.com with ESMTP id o56MYo6t015668
	for <linux-mm@kvack.org>; Sun, 6 Jun 2010 15:34:51 -0700
Received: by pwj8 with SMTP id 8so1402614pwj.12
        for <linux-mm@kvack.org>; Sun, 06 Jun 2010 15:34:50 -0700 (PDT)
Date: Sun, 6 Jun 2010 15:34:47 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 14/18] oom: move sysctl declarations to oom.h
In-Reply-To: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1006061526260.32225@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The three oom killer sysctl variables (sysctl_oom_dump_tasks,
sysctl_oom_kill_allocating_task, and sysctl_panic_on_oom) are better
declared in include/linux/oom.h rather than kernel/sysctl.c.

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/oom.h |    5 +++++
 kernel/sysctl.c     |    4 +---
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -44,5 +44,10 @@ static inline void oom_killer_enable(void)
 {
 	oom_killer_disabled = false;
 }
+
+/* sysctls */
+extern int sysctl_oom_dump_tasks;
+extern int sysctl_oom_kill_allocating_task;
+extern int sysctl_panic_on_oom;
 #endif /* __KERNEL__*/
 #endif /* _INCLUDE_LINUX_OOM_H */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -55,6 +55,7 @@
 #include <linux/perf_event.h>
 #include <linux/kprobes.h>
 #include <linux/pipe_fs_i.h>
+#include <linux/oom.h>
 
 #include <asm/uaccess.h>
 #include <asm/processor.h>
@@ -87,9 +88,6 @@
 /* External variables not in a header file. */
 extern int sysctl_overcommit_memory;
 extern int sysctl_overcommit_ratio;
-extern int sysctl_panic_on_oom;
-extern int sysctl_oom_kill_allocating_task;
-extern int sysctl_oom_dump_tasks;
 extern int max_threads;
 extern int core_uses_pid;
 extern int suid_dumpable;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
