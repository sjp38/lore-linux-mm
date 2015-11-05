Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f173.google.com (mail-yk0-f173.google.com [209.85.160.173])
	by kanga.kvack.org (Postfix) with ESMTP id 46CDF82F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 17:30:17 -0500 (EST)
Received: by ykba4 with SMTP id a4so158296145ykb.3
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 14:30:17 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e194si6536962vkf.89.2015.11.05.14.30.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Nov 2015 14:30:16 -0800 (PST)
Message-Id: <20151105223014.909080166@redhat.com>
Date: Thu, 05 Nov 2015 17:30:18 -0500
From: aris@redhat.com
Subject: [PATCH 4/5] x86: dumpstack - implement show_stack_lvl()
References: <20151105223014.701269769@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline; filename=arch-x86.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kerne@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>

show_stack_lvl() allows passing the log level and is used by dump_stack_lvl().

Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Greg Thelen <gthelen@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>
Signed-off-by: Aristeu Rozanski <aris@redhat.com>

---
 arch/x86/kernel/dumpstack.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

--- linux-2.6.orig/arch/x86/kernel/dumpstack.c	2015-11-05 13:33:30.994378877 -0500
+++ linux-2.6/arch/x86/kernel/dumpstack.c	2015-11-05 13:44:37.014856773 -0500
@@ -180,7 +180,7 @@ void show_trace(struct task_struct *task
 	show_trace_log_lvl(task, regs, stack, bp, "");
 }
 
-void show_stack(struct task_struct *task, unsigned long *sp)
+void show_stack_lvl(struct task_struct *task, unsigned long *sp, char *log_lvl)
 {
 	unsigned long bp = 0;
 	unsigned long stack;
@@ -194,7 +194,12 @@ unsigned long bp = 0;
 		bp = stack_frame(current, NULL);
 	}
 
-	show_stack_log_lvl(task, NULL, sp, bp, "");
+	show_stack_log_lvl(task, NULL, sp, bp, log_lvl);
+}
+
+void show_stack(struct task_struct *task, unsigned long *sp)
+{
+	show_stack_lvl(task, sp, KERN_DEFAULT);
 }
 
 static arch_spinlock_t die_lock = __ARCH_SPIN_LOCK_UNLOCKED;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
