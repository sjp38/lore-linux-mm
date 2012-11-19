Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id C835E6B005D
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 13:27:24 -0500 (EST)
From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 019/493] mm: remove CONFIG_HOTPLUG ifdefs
Date: Mon, 19 Nov 2012 13:19:28 -0500
Message-Id: <1353349642-3677-19-git-send-email-wfp5p@virginia.edu>
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org
Cc: linux-mm@kvack.org

Remove conditional code based on CONFIG_HOTPLUG being false.  It's
always on now in preparation of it going away as an option.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: linux-mm@kvack.org 
---
 include/linux/vmstat.h | 6 ------
 mm/vmstat.c            | 2 --
 2 files changed, 8 deletions(-)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 92a86b2..d472dd8 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -48,13 +48,7 @@ static inline void count_vm_events(enum vm_event_item item, long delta)
 }
 
 extern void all_vm_events(unsigned long *);
-#ifdef CONFIG_HOTPLUG
 extern void vm_events_fold_cpu(int cpu);
-#else
-static inline void vm_events_fold_cpu(int cpu)
-{
-}
-#endif
 
 #else
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 34bf80b..a999171 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -52,7 +52,6 @@ void all_vm_events(unsigned long *ret)
 }
 EXPORT_SYMBOL_GPL(all_vm_events);
 
-#ifdef CONFIG_HOTPLUG
 /*
  * Fold the foreign cpu events into our own.
  *
@@ -69,7 +68,6 @@ void vm_events_fold_cpu(int cpu)
 		fold_state->event[i] = 0;
 	}
 }
-#endif /* CONFIG_HOTPLUG */
 
 #endif /* CONFIG_VM_EVENT_COUNTERS */
 
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
