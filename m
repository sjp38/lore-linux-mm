Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 479706B008C
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 06:23:21 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 17/43] sched, mm, x86: Add the ARCH_SUPPORTS_NUMA_BALANCING flag
Date: Fri, 16 Nov 2012 11:22:27 +0000
Message-Id: <1353064973-26082-18-git-send-email-mgorman@suse.de>
In-Reply-To: <1353064973-26082-1-git-send-email-mgorman@suse.de>
References: <1353064973-26082-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Ingo Molnar <mingo@kernel.org>

Allow architectures to opt-in to the adaptive affinity NUMA balancing code.

Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 init/Kconfig |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/init/Kconfig b/init/Kconfig
index 6fdd6e3..17434ca 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -696,6 +696,13 @@ config LOG_BUF_SHIFT
 config HAVE_UNSTABLE_SCHED_CLOCK
 	bool
 
+#
+# For architectures that want to enable the PROT_NUMA driven,
+# NUMA-affine scheduler balancing logic:
+#
+config ARCH_SUPPORTS_NUMA_BALANCING
+	bool
+
 menuconfig CGROUPS
 	boolean "Control Group support"
 	depends on EVENTFD
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
