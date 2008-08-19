Received: by ti-out-0910.google.com with SMTP id j3so27673tid.8
        for <linux-mm@kvack.org>; Tue, 19 Aug 2008 10:46:45 -0700 (PDT)
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: [PATCH 1/5] Revert "kmemtrace: fix printk format warnings"
Date: Tue, 19 Aug 2008 20:43:23 +0300
Message-Id: <1219167807-5407-1-git-send-email-eduard.munteanu@linux360.ro>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: penberg@cs.helsinki.fi
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, rdunlap@xenotime.net, mpm@selenic.com, tglx@linutronix.de, rostedt@goodmis.org, cl@linux-foundation.org, mathieu.desnoyers@polymtl.ca, tzanussi@gmail.com, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
List-ID: <linux-mm.kvack.org>

This reverts commit 79cf3d5e207243eecb1c4331c569e17700fa08fa.

The reverted commit, while it fixed printk format warnings, it resulted in
marker-probe format mismatches. Another approach should be used to fix
these warnings.
---
 include/linux/kmemtrace.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/kmemtrace.h b/include/linux/kmemtrace.h
index a865064..2c33201 100644
--- a/include/linux/kmemtrace.h
+++ b/include/linux/kmemtrace.h
@@ -31,7 +31,7 @@ static inline void kmemtrace_mark_alloc_node(enum kmemtrace_type_id type_id,
 					     int node)
 {
 	trace_mark(kmemtrace_alloc, "type_id %d call_site %lu ptr %lu "
-		   "bytes_req %zu bytes_alloc %zu gfp_flags %lu node %d",
+		   "bytes_req %lu bytes_alloc %lu gfp_flags %lu node %d",
 		   type_id, call_site, (unsigned long) ptr,
 		   bytes_req, bytes_alloc, (unsigned long) gfp_flags, node);
 }
-- 
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
