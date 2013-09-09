Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 3C7346B0034
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 05:16:18 -0400 (EDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: [PATCH 3/3] sched: Remove ARCH specific fpu_counter from task_struct
Date: Mon, 9 Sep 2013 14:45:23 +0530
Message-ID: <1378718123-7372-3-git-send-email-vgupta@synopsys.com>
In-Reply-To: <1378718123-7372-1-git-send-email-vgupta@synopsys.com>
References: <1378718123-7372-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: Vineet Gupta <Vineet.Gupta1@synopsys.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>

fpu_counter in task_struct was used only by sh/x86.
Both of these now carry it in ARCH specific thread_struct, hence this
can now be removed from generic task_struct, shrinking it slightly for
other arches.

Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
---
 include/linux/sched.h | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 078066d..b560364 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1051,15 +1051,6 @@ struct task_struct {
 	struct hlist_head preempt_notifiers;
 #endif
 
-	/*
-	 * fpu_counter contains the number of consecutive context switches
-	 * that the FPU is used. If this is over a threshold, the lazy fpu
-	 * saving becomes unlazy to save the trap. This is an unsigned char
-	 * so that after 256 times the counter wraps and the behavior turns
-	 * lazy again; this to deal with bursty apps that only use FPU for
-	 * a short time
-	 */
-	unsigned char fpu_counter;
 #ifdef CONFIG_BLK_DEV_IO_TRACE
 	unsigned int btrace_seq;
 #endif
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
