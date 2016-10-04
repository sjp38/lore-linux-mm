Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 05DB06B0263
	for <linux-mm@kvack.org>; Tue,  4 Oct 2016 05:00:29 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 7so272786305pfa.2
        for <linux-mm@kvack.org>; Tue, 04 Oct 2016 02:00:28 -0700 (PDT)
Received: from mail-pf0-f194.google.com (mail-pf0-f194.google.com. [209.85.192.194])
        by mx.google.com with ESMTPS id dy9si2693007pab.143.2016.10.04.02.00.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Oct 2016 02:00:28 -0700 (PDT)
Received: by mail-pf0-f194.google.com with SMTP id i85so3443250pfa.0
        for <linux-mm@kvack.org>; Tue, 04 Oct 2016 02:00:28 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 4/4] arch: get rid of TIF_MEMDIE
Date: Tue,  4 Oct 2016 11:00:09 +0200
Message-Id: <20161004090009.7974-5-mhocko@kernel.org>
In-Reply-To: <20161004090009.7974-1-mhocko@kernel.org>
References: <20161004090009.7974-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

nobody relies on the flag so make it go away.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/alpha/include/asm/thread_info.h      | 1 -
 arch/arc/include/asm/thread_info.h        | 2 --
 arch/arm/include/asm/thread_info.h        | 1 -
 arch/arm64/include/asm/thread_info.h      | 1 -
 arch/avr32/include/asm/thread_info.h      | 2 --
 arch/blackfin/include/asm/thread_info.h   | 1 -
 arch/c6x/include/asm/thread_info.h        | 1 -
 arch/cris/include/asm/thread_info.h       | 1 -
 arch/frv/include/asm/thread_info.h        | 1 -
 arch/h8300/include/asm/thread_info.h      | 1 -
 arch/hexagon/include/asm/thread_info.h    | 1 -
 arch/ia64/include/asm/thread_info.h       | 1 -
 arch/m32r/include/asm/thread_info.h       | 1 -
 arch/m68k/include/asm/thread_info.h       | 1 -
 arch/metag/include/asm/thread_info.h      | 1 -
 arch/microblaze/include/asm/thread_info.h | 1 -
 arch/mips/include/asm/thread_info.h       | 1 -
 arch/mn10300/include/asm/thread_info.h    | 1 -
 arch/nios2/include/asm/thread_info.h      | 1 -
 arch/openrisc/include/asm/thread_info.h   | 1 -
 arch/parisc/include/asm/thread_info.h     | 1 -
 arch/powerpc/include/asm/thread_info.h    | 1 -
 arch/s390/include/asm/thread_info.h       | 1 -
 arch/score/include/asm/thread_info.h      | 1 -
 arch/sh/include/asm/thread_info.h         | 1 -
 arch/sparc/include/asm/thread_info_32.h   | 1 -
 arch/sparc/include/asm/thread_info_64.h   | 1 -
 arch/tile/include/asm/thread_info.h       | 2 --
 arch/um/include/asm/thread_info.h         | 2 --
 arch/unicore32/include/asm/thread_info.h  | 1 -
 arch/x86/include/asm/thread_info.h        | 1 -
 arch/xtensa/include/asm/thread_info.h     | 1 -
 32 files changed, 36 deletions(-)

diff --git a/arch/alpha/include/asm/thread_info.h b/arch/alpha/include/asm/thread_info.h
index e9e90bfa2b50..8eac8743437e 100644
--- a/arch/alpha/include/asm/thread_info.h
+++ b/arch/alpha/include/asm/thread_info.h
@@ -65,7 +65,6 @@ register struct thread_info *__current_thread_info __asm__("$8");
 #define TIF_NEED_RESCHED	3	/* rescheduling necessary */
 #define TIF_SYSCALL_AUDIT	4	/* syscall audit active */
 #define TIF_DIE_IF_KERNEL	9	/* dik recursion lock */
-#define TIF_MEMDIE		13	/* is terminating due to OOM killer */
 #define TIF_POLLING_NRFLAG	14	/* idle is polling for TIF_NEED_RESCHED */
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
diff --git a/arch/arc/include/asm/thread_info.h b/arch/arc/include/asm/thread_info.h
index 2d79e527fa50..a3f236006a73 100644
--- a/arch/arc/include/asm/thread_info.h
+++ b/arch/arc/include/asm/thread_info.h
@@ -88,14 +88,12 @@ static inline __attribute_const__ struct thread_info *current_thread_info(void)
 #define TIF_SYSCALL_TRACE	15	/* syscall trace active */
 
 /* true if poll_idle() is polling TIF_NEED_RESCHED */
-#define TIF_MEMDIE		16
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
 #define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_SYSCALL_AUDIT	(1<<TIF_SYSCALL_AUDIT)
-#define _TIF_MEMDIE		(1<<TIF_MEMDIE)
 
 /* work to do on interrupt/exception return */
 #define _TIF_WORK_MASK		(_TIF_NEED_RESCHED | _TIF_SIGPENDING | \
diff --git a/arch/arm/include/asm/thread_info.h b/arch/arm/include/asm/thread_info.h
index 776757d1604a..6277e56f15fd 100644
--- a/arch/arm/include/asm/thread_info.h
+++ b/arch/arm/include/asm/thread_info.h
@@ -146,7 +146,6 @@ extern int vfp_restore_user_hwstate(struct user_vfp __user *,
 
 #define TIF_NOHZ		12	/* in adaptive nohz mode */
 #define TIF_USING_IWMMXT	17
-#define TIF_MEMDIE		18	/* is terminating due to OOM killer */
 #define TIF_RESTORE_SIGMASK	20
 
 #define _TIF_SIGPENDING		(1 << TIF_SIGPENDING)
diff --git a/arch/arm64/include/asm/thread_info.h b/arch/arm64/include/asm/thread_info.h
index abd64bd1f6d9..d78b3b2945a9 100644
--- a/arch/arm64/include/asm/thread_info.h
+++ b/arch/arm64/include/asm/thread_info.h
@@ -114,7 +114,6 @@ static inline struct thread_info *current_thread_info(void)
 #define TIF_SYSCALL_AUDIT	9
 #define TIF_SYSCALL_TRACEPOINT	10
 #define TIF_SECCOMP		11
-#define TIF_MEMDIE		18	/* is terminating due to OOM killer */
 #define TIF_FREEZE		19
 #define TIF_RESTORE_SIGMASK	20
 #define TIF_SINGLESTEP		21
diff --git a/arch/avr32/include/asm/thread_info.h b/arch/avr32/include/asm/thread_info.h
index d4d3079541ea..680be13234ab 100644
--- a/arch/avr32/include/asm/thread_info.h
+++ b/arch/avr32/include/asm/thread_info.h
@@ -70,7 +70,6 @@ static inline struct thread_info *current_thread_info(void)
 #define TIF_NEED_RESCHED        2       /* rescheduling necessary */
 #define TIF_BREAKPOINT		4	/* enter monitor mode on return */
 #define TIF_SINGLE_STEP		5	/* single step in progress */
-#define TIF_MEMDIE		6	/* is terminating due to OOM killer */
 #define TIF_RESTORE_SIGMASK	7	/* restore signal mask in do_signal */
 #define TIF_CPU_GOING_TO_SLEEP	8	/* CPU is entering sleep 0 mode */
 #define TIF_NOTIFY_RESUME	9	/* callback before returning to user */
@@ -82,7 +81,6 @@ static inline struct thread_info *current_thread_info(void)
 #define _TIF_NEED_RESCHED	(1 << TIF_NEED_RESCHED)
 #define _TIF_BREAKPOINT		(1 << TIF_BREAKPOINT)
 #define _TIF_SINGLE_STEP	(1 << TIF_SINGLE_STEP)
-#define _TIF_MEMDIE		(1 << TIF_MEMDIE)
 #define _TIF_CPU_GOING_TO_SLEEP (1 << TIF_CPU_GOING_TO_SLEEP)
 #define _TIF_NOTIFY_RESUME	(1 << TIF_NOTIFY_RESUME)
 
diff --git a/arch/blackfin/include/asm/thread_info.h b/arch/blackfin/include/asm/thread_info.h
index 2966b93850a1..a45ff075ab6a 100644
--- a/arch/blackfin/include/asm/thread_info.h
+++ b/arch/blackfin/include/asm/thread_info.h
@@ -79,7 +79,6 @@ static inline struct thread_info *current_thread_info(void)
 #define TIF_SYSCALL_TRACE	0	/* syscall trace active */
 #define TIF_SIGPENDING		1	/* signal pending */
 #define TIF_NEED_RESCHED	2	/* rescheduling necessary */
-#define TIF_MEMDIE		4	/* is terminating due to OOM killer */
 #define TIF_RESTORE_SIGMASK	5	/* restore signal mask in do_signal() */
 #define TIF_IRQ_SYNC		7	/* sync pipeline stage */
 #define TIF_NOTIFY_RESUME	8	/* callback before returning to user */
diff --git a/arch/c6x/include/asm/thread_info.h b/arch/c6x/include/asm/thread_info.h
index acc70c135ab8..22ff7b03641d 100644
--- a/arch/c6x/include/asm/thread_info.h
+++ b/arch/c6x/include/asm/thread_info.h
@@ -89,7 +89,6 @@ struct thread_info *current_thread_info(void)
 #define TIF_NEED_RESCHED	3	/* rescheduling necessary */
 #define TIF_RESTORE_SIGMASK	4	/* restore signal mask in do_signal() */
 
-#define TIF_MEMDIE		17	/* OOM killer killed process */
 
 #define TIF_WORK_MASK		0x00007FFE /* work on irq/exception return */
 #define TIF_ALLWORK_MASK	0x00007FFF /* work on any return to u-space */
diff --git a/arch/cris/include/asm/thread_info.h b/arch/cris/include/asm/thread_info.h
index 4ead1b40d2d7..79ebddc22aa3 100644
--- a/arch/cris/include/asm/thread_info.h
+++ b/arch/cris/include/asm/thread_info.h
@@ -70,7 +70,6 @@ struct thread_info {
 #define TIF_SIGPENDING		2	/* signal pending */
 #define TIF_NEED_RESCHED	3	/* rescheduling necessary */
 #define TIF_RESTORE_SIGMASK	9	/* restore signal mask in do_signal() */
-#define TIF_MEMDIE		17	/* is terminating due to OOM killer */
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
 #define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
diff --git a/arch/frv/include/asm/thread_info.h b/arch/frv/include/asm/thread_info.h
index ccba3b6ce918..993930f59d8e 100644
--- a/arch/frv/include/asm/thread_info.h
+++ b/arch/frv/include/asm/thread_info.h
@@ -86,7 +86,6 @@ register struct thread_info *__current_thread_info asm("gr15");
 #define TIF_NEED_RESCHED	3	/* rescheduling necessary */
 #define TIF_SINGLESTEP		4	/* restore singlestep on return to user mode */
 #define TIF_RESTORE_SIGMASK	5	/* restore signal mask in do_signal() */
-#define TIF_MEMDIE		7	/* is terminating due to OOM killer */
 
 #define _TIF_SYSCALL_TRACE	(1 << TIF_SYSCALL_TRACE)
 #define _TIF_NOTIFY_RESUME	(1 << TIF_NOTIFY_RESUME)
diff --git a/arch/h8300/include/asm/thread_info.h b/arch/h8300/include/asm/thread_info.h
index b408fe660cf8..68c10bce921e 100644
--- a/arch/h8300/include/asm/thread_info.h
+++ b/arch/h8300/include/asm/thread_info.h
@@ -73,7 +73,6 @@ static inline struct thread_info *current_thread_info(void)
 #define TIF_SIGPENDING		1	/* signal pending */
 #define TIF_NEED_RESCHED	2	/* rescheduling necessary */
 #define TIF_SINGLESTEP		3	/* singlestepping active */
-#define TIF_MEMDIE		4	/* is terminating due to OOM killer */
 #define TIF_RESTORE_SIGMASK	5	/* restore signal mask in do_signal() */
 #define TIF_NOTIFY_RESUME	6	/* callback before returning to user */
 #define TIF_SYSCALL_AUDIT	7	/* syscall auditing active */
diff --git a/arch/hexagon/include/asm/thread_info.h b/arch/hexagon/include/asm/thread_info.h
index b80fe1db7b64..e55c7d0a1755 100644
--- a/arch/hexagon/include/asm/thread_info.h
+++ b/arch/hexagon/include/asm/thread_info.h
@@ -112,7 +112,6 @@ register struct thread_info *__current_thread_info asm(QUOTED_THREADINFO_REG);
 #define TIF_SINGLESTEP          4       /* restore ss @ return to usr mode */
 #define TIF_RESTORE_SIGMASK     6       /* restore sig mask in do_signal() */
 /* true if poll_idle() is polling TIF_NEED_RESCHED */
-#define TIF_MEMDIE              17      /* OOM killer killed process */
 
 #define _TIF_SYSCALL_TRACE      (1 << TIF_SYSCALL_TRACE)
 #define _TIF_NOTIFY_RESUME      (1 << TIF_NOTIFY_RESUME)
diff --git a/arch/ia64/include/asm/thread_info.h b/arch/ia64/include/asm/thread_info.h
index 29bd59790d6c..321b23dc1bdd 100644
--- a/arch/ia64/include/asm/thread_info.h
+++ b/arch/ia64/include/asm/thread_info.h
@@ -97,7 +97,6 @@ struct thread_info {
 #define TIF_SYSCALL_AUDIT	3	/* syscall auditing active */
 #define TIF_SINGLESTEP		4	/* restore singlestep on return to user mode */
 #define TIF_NOTIFY_RESUME	6	/* resumption notification requested */
-#define TIF_MEMDIE		17	/* is terminating due to OOM killer */
 #define TIF_MCA_INIT		18	/* this task is processing MCA or INIT */
 #define TIF_DB_DISABLED		19	/* debug trap disabled for fsyscall */
 #define TIF_RESTORE_RSE		21	/* user RBS is newer than kernel RBS */
diff --git a/arch/m32r/include/asm/thread_info.h b/arch/m32r/include/asm/thread_info.h
index f630d9c30b28..bc54a574fad0 100644
--- a/arch/m32r/include/asm/thread_info.h
+++ b/arch/m32r/include/asm/thread_info.h
@@ -102,7 +102,6 @@ static inline unsigned int get_thread_fault_code(void)
 #define TIF_NOTIFY_RESUME	5	/* callback before returning to user */
 #define TIF_RESTORE_SIGMASK	8	/* restore signal mask in do_signal() */
 #define TIF_USEDFPU		16	/* FPU was used by this task this quantum (SMP) */
-#define TIF_MEMDIE		18	/* is terminating due to OOM killer */
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
diff --git a/arch/m68k/include/asm/thread_info.h b/arch/m68k/include/asm/thread_info.h
index cee13c2e5161..ed497d31ea5d 100644
--- a/arch/m68k/include/asm/thread_info.h
+++ b/arch/m68k/include/asm/thread_info.h
@@ -68,7 +68,6 @@ static inline struct thread_info *current_thread_info(void)
 #define TIF_NEED_RESCHED	7	/* rescheduling necessary */
 #define TIF_DELAYED_TRACE	14	/* single step a syscall */
 #define TIF_SYSCALL_TRACE	15	/* syscall trace active */
-#define TIF_MEMDIE		16	/* is terminating due to OOM killer */
 #define TIF_RESTORE_SIGMASK	18	/* restore signal mask in do_signal */
 
 #endif	/* _ASM_M68K_THREAD_INFO_H */
diff --git a/arch/metag/include/asm/thread_info.h b/arch/metag/include/asm/thread_info.h
index 32677cc278aa..c506e5a61714 100644
--- a/arch/metag/include/asm/thread_info.h
+++ b/arch/metag/include/asm/thread_info.h
@@ -111,7 +111,6 @@ static inline int kstack_end(void *addr)
 #define TIF_SECCOMP		5	/* secure computing */
 #define TIF_RESTORE_SIGMASK	6	/* restore signal mask in do_signal() */
 #define TIF_NOTIFY_RESUME	7	/* callback before returning to user */
-#define TIF_MEMDIE		8	/* is terminating due to OOM killer */
 #define TIF_SYSCALL_TRACEPOINT	9	/* syscall tracepoint instrumentation */
 
 
diff --git a/arch/microblaze/include/asm/thread_info.h b/arch/microblaze/include/asm/thread_info.h
index e7e8954e9815..63cf6e8c086f 100644
--- a/arch/microblaze/include/asm/thread_info.h
+++ b/arch/microblaze/include/asm/thread_info.h
@@ -113,7 +113,6 @@ static inline struct thread_info *current_thread_info(void)
 #define TIF_NEED_RESCHED	3 /* rescheduling necessary */
 /* restore singlestep on return to user mode */
 #define TIF_SINGLESTEP		4
-#define TIF_MEMDIE		6	/* is terminating due to OOM killer */
 #define TIF_SYSCALL_AUDIT	9       /* syscall auditing active */
 #define TIF_SECCOMP		10      /* secure computing */
 
diff --git a/arch/mips/include/asm/thread_info.h b/arch/mips/include/asm/thread_info.h
index e309d8fcb516..3dd906330867 100644
--- a/arch/mips/include/asm/thread_info.h
+++ b/arch/mips/include/asm/thread_info.h
@@ -102,7 +102,6 @@ static inline struct thread_info *current_thread_info(void)
 #define TIF_UPROBE		6	/* breakpointed or singlestepping */
 #define TIF_RESTORE_SIGMASK	9	/* restore signal mask in do_signal() */
 #define TIF_USEDFPU		16	/* FPU was used by this task this quantum (SMP) */
-#define TIF_MEMDIE		18	/* is terminating due to OOM killer */
 #define TIF_NOHZ		19	/* in adaptive nohz mode */
 #define TIF_FIXADE		20	/* Fix address errors in software */
 #define TIF_LOGADE		21	/* Log address errors to syslog */
diff --git a/arch/mn10300/include/asm/thread_info.h b/arch/mn10300/include/asm/thread_info.h
index f5f90bbf019d..d992e6d1b718 100644
--- a/arch/mn10300/include/asm/thread_info.h
+++ b/arch/mn10300/include/asm/thread_info.h
@@ -145,7 +145,6 @@ void arch_release_thread_stack(unsigned long *stack);
 #define TIF_SINGLESTEP		4	/* restore singlestep on return to user mode */
 #define TIF_RESTORE_SIGMASK	5	/* restore signal mask in do_signal() */
 #define TIF_POLLING_NRFLAG	16	/* true if poll_idle() is polling TIF_NEED_RESCHED */
-#define TIF_MEMDIE		17	/* is terminating due to OOM killer */
 
 #define _TIF_SYSCALL_TRACE	+(1 << TIF_SYSCALL_TRACE)
 #define _TIF_NOTIFY_RESUME	+(1 << TIF_NOTIFY_RESUME)
diff --git a/arch/nios2/include/asm/thread_info.h b/arch/nios2/include/asm/thread_info.h
index d69c338bd19c..bf7d38c1c6e2 100644
--- a/arch/nios2/include/asm/thread_info.h
+++ b/arch/nios2/include/asm/thread_info.h
@@ -86,7 +86,6 @@ static inline struct thread_info *current_thread_info(void)
 #define TIF_NOTIFY_RESUME	1	/* resumption notification requested */
 #define TIF_SIGPENDING		2	/* signal pending */
 #define TIF_NEED_RESCHED	3	/* rescheduling necessary */
-#define TIF_MEMDIE		4	/* is terminating due to OOM killer */
 #define TIF_SECCOMP		5	/* secure computing */
 #define TIF_SYSCALL_AUDIT	6	/* syscall auditing active */
 #define TIF_RESTORE_SIGMASK	9	/* restore signal mask in do_signal() */
diff --git a/arch/openrisc/include/asm/thread_info.h b/arch/openrisc/include/asm/thread_info.h
index 6e619a79a401..7678a1b2dc64 100644
--- a/arch/openrisc/include/asm/thread_info.h
+++ b/arch/openrisc/include/asm/thread_info.h
@@ -108,7 +108,6 @@ register struct thread_info *current_thread_info_reg asm("r10");
 #define TIF_RESTORE_SIGMASK     9
 #define TIF_POLLING_NRFLAG	16	/* true if poll_idle() is polling						 * TIF_NEED_RESCHED
 					 */
-#define TIF_MEMDIE              17
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
 #define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
diff --git a/arch/parisc/include/asm/thread_info.h b/arch/parisc/include/asm/thread_info.h
index 7581330ea35b..05ea8af5865d 100644
--- a/arch/parisc/include/asm/thread_info.h
+++ b/arch/parisc/include/asm/thread_info.h
@@ -48,7 +48,6 @@ struct thread_info {
 #define TIF_NEED_RESCHED	2	/* rescheduling necessary */
 #define TIF_POLLING_NRFLAG	3	/* true if poll_idle() is polling TIF_NEED_RESCHED */
 #define TIF_32BIT               4       /* 32 bit binary */
-#define TIF_MEMDIE		5	/* is terminating due to OOM killer */
 #define TIF_RESTORE_SIGMASK	6	/* restore saved signal mask */
 #define TIF_SYSCALL_AUDIT	7	/* syscall auditing active */
 #define TIF_NOTIFY_RESUME	8	/* callback before returning to user */
diff --git a/arch/powerpc/include/asm/thread_info.h b/arch/powerpc/include/asm/thread_info.h
index cfc35195f95e..315a924af2ca 100644
--- a/arch/powerpc/include/asm/thread_info.h
+++ b/arch/powerpc/include/asm/thread_info.h
@@ -99,7 +99,6 @@ static inline struct thread_info *current_thread_info(void)
 #define TIF_SYSCALL_TRACEPOINT	15	/* syscall tracepoint instrumentation */
 #define TIF_EMULATE_STACK_STORE	16	/* Is an instruction emulation
 						for stack store? */
-#define TIF_MEMDIE		17	/* is terminating due to OOM killer */
 #if defined(CONFIG_PPC64)
 #define TIF_ELF2ABI		18	/* function descriptors must die! */
 #endif
diff --git a/arch/s390/include/asm/thread_info.h b/arch/s390/include/asm/thread_info.h
index f15c0398c363..7261dafde433 100644
--- a/arch/s390/include/asm/thread_info.h
+++ b/arch/s390/include/asm/thread_info.h
@@ -80,7 +80,6 @@ int arch_dup_task_struct(struct task_struct *dst, struct task_struct *src);
 #define TIF_SYSCALL_TRACEPOINT	6	/* syscall tracepoint instrumentation */
 #define TIF_UPROBE		7	/* breakpointed or single-stepping */
 #define TIF_31BIT		16	/* 32bit process */
-#define TIF_MEMDIE		17	/* is terminating due to OOM killer */
 #define TIF_RESTORE_SIGMASK	18	/* restore signal mask in do_signal() */
 #define TIF_SINGLE_STEP		19	/* This task is single stepped */
 #define TIF_BLOCK_STEP		20	/* This task is block stepped */
diff --git a/arch/score/include/asm/thread_info.h b/arch/score/include/asm/thread_info.h
index 7d9ffb15c477..f6e1cc89cef9 100644
--- a/arch/score/include/asm/thread_info.h
+++ b/arch/score/include/asm/thread_info.h
@@ -78,7 +78,6 @@ register struct thread_info *__current_thread_info __asm__("r28");
 #define TIF_NEED_RESCHED	2	/* rescheduling necessary */
 #define TIF_NOTIFY_RESUME	5	/* callback before returning to user */
 #define TIF_RESTORE_SIGMASK	9	/* restore signal mask in do_signal() */
-#define TIF_MEMDIE		18	/* is terminating due to OOM killer */
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
diff --git a/arch/sh/include/asm/thread_info.h b/arch/sh/include/asm/thread_info.h
index 6c65dcd470ab..36d15c6e36e5 100644
--- a/arch/sh/include/asm/thread_info.h
+++ b/arch/sh/include/asm/thread_info.h
@@ -117,7 +117,6 @@ extern void init_thread_xstate(void);
 #define TIF_NOTIFY_RESUME	7	/* callback before returning to user */
 #define TIF_SYSCALL_TRACEPOINT	8	/* for ftrace syscall instrumentation */
 #define TIF_POLLING_NRFLAG	17	/* true if poll_idle() is polling TIF_NEED_RESCHED */
-#define TIF_MEMDIE		18	/* is terminating due to OOM killer */
 
 #define _TIF_SYSCALL_TRACE	(1 << TIF_SYSCALL_TRACE)
 #define _TIF_SIGPENDING		(1 << TIF_SIGPENDING)
diff --git a/arch/sparc/include/asm/thread_info_32.h b/arch/sparc/include/asm/thread_info_32.h
index 229475f0d7ce..bcf81999db0b 100644
--- a/arch/sparc/include/asm/thread_info_32.h
+++ b/arch/sparc/include/asm/thread_info_32.h
@@ -110,7 +110,6 @@ register struct thread_info *current_thread_info_reg asm("g6");
 					 * this quantum (SMP) */
 #define TIF_POLLING_NRFLAG	9	/* true if poll_idle() is polling
 					 * TIF_NEED_RESCHED */
-#define TIF_MEMDIE		10	/* is terminating due to OOM killer */
 
 /* as above, but as bit values */
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
diff --git a/arch/sparc/include/asm/thread_info_64.h b/arch/sparc/include/asm/thread_info_64.h
index 3d7b925f6516..69612d8355f1 100644
--- a/arch/sparc/include/asm/thread_info_64.h
+++ b/arch/sparc/include/asm/thread_info_64.h
@@ -191,7 +191,6 @@ register struct thread_info *current_thread_info_reg asm("g6");
  *       an immediate value in instructions such as andcc.
  */
 /* flag bit 12 is available */
-#define TIF_MEMDIE		13	/* is terminating due to OOM killer */
 #define TIF_POLLING_NRFLAG	14
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
diff --git a/arch/tile/include/asm/thread_info.h b/arch/tile/include/asm/thread_info.h
index b7659b8f1117..1ecdc1111052 100644
--- a/arch/tile/include/asm/thread_info.h
+++ b/arch/tile/include/asm/thread_info.h
@@ -121,7 +121,6 @@ extern void _cpu_idle(void);
 #define TIF_SYSCALL_TRACE	4	/* syscall trace active */
 #define TIF_SYSCALL_AUDIT	5	/* syscall auditing active */
 #define TIF_SECCOMP		6	/* secure computing */
-#define TIF_MEMDIE		7	/* OOM killer at work */
 #define TIF_NOTIFY_RESUME	8	/* callback before returning to user */
 #define TIF_SYSCALL_TRACEPOINT	9	/* syscall tracepoint instrumentation */
 #define TIF_POLLING_NRFLAG	10	/* idle is polling for TIF_NEED_RESCHED */
@@ -134,7 +133,6 @@ extern void _cpu_idle(void);
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
 #define _TIF_SYSCALL_AUDIT	(1<<TIF_SYSCALL_AUDIT)
 #define _TIF_SECCOMP		(1<<TIF_SECCOMP)
-#define _TIF_MEMDIE		(1<<TIF_MEMDIE)
 #define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
 #define _TIF_SYSCALL_TRACEPOINT	(1<<TIF_SYSCALL_TRACEPOINT)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
diff --git a/arch/um/include/asm/thread_info.h b/arch/um/include/asm/thread_info.h
index 053baff03674..b13047eeaede 100644
--- a/arch/um/include/asm/thread_info.h
+++ b/arch/um/include/asm/thread_info.h
@@ -58,7 +58,6 @@ static inline struct thread_info *current_thread_info(void)
 #define TIF_SIGPENDING		1	/* signal pending */
 #define TIF_NEED_RESCHED	2	/* rescheduling necessary */
 #define TIF_RESTART_BLOCK	4
-#define TIF_MEMDIE		5	/* is terminating due to OOM killer */
 #define TIF_SYSCALL_AUDIT	6
 #define TIF_RESTORE_SIGMASK	7
 #define TIF_NOTIFY_RESUME	8
@@ -67,7 +66,6 @@ static inline struct thread_info *current_thread_info(void)
 #define _TIF_SYSCALL_TRACE	(1 << TIF_SYSCALL_TRACE)
 #define _TIF_SIGPENDING		(1 << TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1 << TIF_NEED_RESCHED)
-#define _TIF_MEMDIE		(1 << TIF_MEMDIE)
 #define _TIF_SYSCALL_AUDIT	(1 << TIF_SYSCALL_AUDIT)
 #define _TIF_SECCOMP		(1 << TIF_SECCOMP)
 
diff --git a/arch/unicore32/include/asm/thread_info.h b/arch/unicore32/include/asm/thread_info.h
index e79ad6d5b5b2..2487cf9dd41e 100644
--- a/arch/unicore32/include/asm/thread_info.h
+++ b/arch/unicore32/include/asm/thread_info.h
@@ -121,7 +121,6 @@ static inline struct thread_info *current_thread_info(void)
 #define TIF_NEED_RESCHED	1
 #define TIF_NOTIFY_RESUME	2	/* callback before returning to user */
 #define TIF_SYSCALL_TRACE	8
-#define TIF_MEMDIE		18
 #define TIF_RESTORE_SIGMASK	20
 
 #define _TIF_SIGPENDING		(1 << TIF_SIGPENDING)
diff --git a/arch/x86/include/asm/thread_info.h b/arch/x86/include/asm/thread_info.h
index b45ffdda3549..a897f177b004 100644
--- a/arch/x86/include/asm/thread_info.h
+++ b/arch/x86/include/asm/thread_info.h
@@ -97,7 +97,6 @@ struct thread_info {
 #define TIF_IA32		17	/* IA32 compatibility process */
 #define TIF_FORK		18	/* ret_from_fork */
 #define TIF_NOHZ		19	/* in adaptive nohz mode */
-#define TIF_MEMDIE		20	/* is terminating due to OOM killer */
 #define TIF_POLLING_NRFLAG	21	/* idle is polling for TIF_NEED_RESCHED */
 #define TIF_IO_BITMAP		22	/* uses I/O bitmap */
 #define TIF_FORCED_TF		24	/* true if TF in eflags artificially */
diff --git a/arch/xtensa/include/asm/thread_info.h b/arch/xtensa/include/asm/thread_info.h
index 7be2400f745a..791a0a0b5827 100644
--- a/arch/xtensa/include/asm/thread_info.h
+++ b/arch/xtensa/include/asm/thread_info.h
@@ -108,7 +108,6 @@ static inline struct thread_info *current_thread_info(void)
 #define TIF_SIGPENDING		1	/* signal pending */
 #define TIF_NEED_RESCHED	2	/* rescheduling necessary */
 #define TIF_SINGLESTEP		3	/* restore singlestep on return to user mode */
-#define TIF_MEMDIE		5	/* is terminating due to OOM killer */
 #define TIF_RESTORE_SIGMASK	6	/* restore signal mask in do_signal() */
 #define TIF_NOTIFY_RESUME	7	/* callback before returning to user */
 #define TIF_DB_DISABLED		8	/* debug trap disabled for syscall */
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
