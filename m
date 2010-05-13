Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 64CA86B01E3
	for <linux-mm@kvack.org>; Thu, 13 May 2010 17:51:41 -0400 (EDT)
From: Andreas Dilger <adilger@dilger.ca>
Content-Type: multipart/mixed; boundary=Apple-Mail-13--872443955
Subject: [PATCH 1/1] mm: add descriptive comment for TIF_MEMDIE declaration
Date: Thu, 13 May 2010 15:51:39 -0600
Message-Id: <930863A4-0E91-4994-8EA0-E18361B0113D@dilger.ca>
Mime-Version: 1.0 (Apple Message framework v1078)
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: "linux-kernel@vger.kernel.org Mailinglist" <linux-kernel@vger.kernel.org>, trivial@kernel.org
List-ID: <linux-mm.kvack.org>


--Apple-Mail-13--872443955
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii

From: Andreas Dilger <adilger@dilger.ca>

Add descriptive comment for TIF_MEMDIE task flag declaration.

Signed-off-by: Andreas Dilger <adilger@dilger.ca>

---
Cheers, Andreas


--Apple-Mail-13--872443955
Content-Disposition: attachment;
	filename=tif-memdie.diff
Content-Type: application/octet-stream;
	name="tif-memdie.diff"
Content-Transfer-Encoding: 7bit

From: Andreas Dilger <adilger@dilger.ca>

Add descriptive comment for TIF_MEMDIE task flag declaration.

Signed-off-by: Andreas Dilger <adilger@dilger.ca>

alpha/include/asm/thread_info.h      |    2 +-
arm/include/asm/thread_info.h        |    2 +-
avr32/include/asm/thread_info.h      |    2 +-
blackfin/include/asm/thread_info.h   |    2 +-
cris/include/asm/thread_info.h       |    2 +-
frv/include/asm/thread_info.h        |    2 +-
h8300/include/asm/thread_info.h      |    2 +-
ia64/include/asm/thread_info.h       |    2 +-
m32r/include/asm/thread_info.h       |    2 +-
m68k/include/asm/thread_info_mm.h    |    2 +-
m68k/include/asm/thread_info_no.h    |    2 +-
microblaze/include/asm/thread_info.h |    2 +-
mips/include/asm/thread_info.h       |    2 +-
mn10300/include/asm/thread_info.h    |    2 +-
parisc/include/asm/thread_info.h     |    2 +-
powerpc/include/asm/thread_info.h    |    2 +-
s390/include/asm/thread_info.h       |    2 +-
score/include/asm/thread_info.h      |    2 +-
sh/include/asm/thread_info.h         |    2 +-
sparc/include/asm/thread_info_32.h   |    2 +-
sparc/include/asm/thread_info_64.h   |    2 +-
um/include/asm/thread_info.h         |    7 +++----
x86/include/asm/thread_info.h        |    2 +-
xtensa/include/asm/thread_info.h     |    2 +-
24 files changed, 26 insertions(+), 27 deletions(-)

diff --git a/arch/alpha/include/asm/thread_info.h b/arch/alpha/include/asm/thread_info.h
index b3e8886..791a612 100644
--- a/arch/alpha/include/asm/thread_info.h
+++ b/arch/alpha/include/asm/thread_info.h
@@ -77,7 +77,7 @@ register struct thread_info *__current_thread_info __asm__("$8");
 #define TIF_UAC_NOPRINT		10	/* see sysinfo.h */
 #define TIF_UAC_NOFIX		11
 #define TIF_UAC_SIGBUS		12
-#define TIF_MEMDIE		13
+#define TIF_MEMDIE		13	/* is terminating due to OOM killer */
 #define TIF_RESTORE_SIGMASK	14	/* restore signal mask in do_signal */
 #define TIF_FREEZE		16	/* is freezing for suspend */
 
diff --git a/arch/arm/include/asm/thread_info.h b/arch/arm/include/asm/thread_info.h
index b74970e..b8ec0c4 100644
--- a/arch/arm/include/asm/thread_info.h
+++ b/arch/arm/include/asm/thread_info.h
@@ -141,7 +141,7 @@ extern void vfp_flush_hwstate(struct thread_info *);
 #define TIF_SYSCALL_TRACE	8
 #define TIF_POLLING_NRFLAG	16
 #define TIF_USING_IWMMXT	17
-#define TIF_MEMDIE		18
+#define TIF_MEMDIE		18	/* is terminating due to OOM killer */
 #define TIF_FREEZE		19
 #define TIF_RESTORE_SIGMASK	20
 
diff --git a/arch/avr32/include/asm/thread_info.h b/arch/avr32/include/asm/thread_info.h
index fd0c5d7..9c247db 100644
--- a/arch/avr32/include/asm/thread_info.h
+++ b/arch/avr32/include/asm/thread_info.h
@@ -81,7 +81,7 @@ static inline struct thread_info *current_thread_info(void)
 					   TIF_NEED_RESCHED */
 #define TIF_BREAKPOINT		4	/* enter monitor mode on return */
 #define TIF_SINGLE_STEP		5	/* single step in progress */
-#define TIF_MEMDIE		6
+#define TIF_MEMDIE		6	/* is terminating due to OOM killer */
 #define TIF_RESTORE_SIGMASK	7	/* restore signal mask in do_signal */
 #define TIF_CPU_GOING_TO_SLEEP	8	/* CPU is entering sleep 0 mode */
 #define TIF_NOTIFY_RESUME	9	/* callback before returning to user */
diff --git a/arch/blackfin/include/asm/thread_info.h b/arch/blackfin/include/asm/thread_info.h
index e9a5614..f6ff1fb 100644
--- a/arch/blackfin/include/asm/thread_info.h
+++ b/arch/blackfin/include/asm/thread_info.h
@@ -98,7 +98,7 @@ static inline struct thread_info *current_thread_info(void)
 #define TIF_NEED_RESCHED	2	/* rescheduling necessary */
 #define TIF_POLLING_NRFLAG	3	/* true if poll_idle() is polling
 					   TIF_NEED_RESCHED */
-#define TIF_MEMDIE		4
+#define TIF_MEMDIE		4	/* is terminating due to OOM killer */
 #define TIF_RESTORE_SIGMASK	5	/* restore signal mask in do_signal() */
 #define TIF_FREEZE		6	/* is freezing for suspend */
 #define TIF_IRQ_SYNC		7	/* sync pipeline stage */
diff --git a/arch/cris/include/asm/thread_info.h b/arch/cris/include/asm/thread_info.h
index c3aade3..a20164d 100644
--- a/arch/cris/include/asm/thread_info.h
+++ b/arch/cris/include/asm/thread_info.h
@@ -85,7 +85,7 @@ struct thread_info {
 #define TIF_NEED_RESCHED	3	/* rescheduling necessary */
 #define TIF_RESTORE_SIGMASK	9	/* restore signal mask in do_signal() */
 #define TIF_POLLING_NRFLAG	16	/* true if poll_idle() is polling TIF_NEED_RESCHED */
-#define TIF_MEMDIE		17
+#define TIF_MEMDIE		17	/* is terminating due to OOM killer */
 #define TIF_FREEZE		18	/* is freezing for suspend */
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
diff --git a/arch/frv/include/asm/thread_info.h b/arch/frv/include/asm/thread_info.h
index e608e05..a7eec1d 100644
--- a/arch/frv/include/asm/thread_info.h
+++ b/arch/frv/include/asm/thread_info.h
@@ -113,7 +113,7 @@ register struct thread_info *__current_thread_info asm("gr15");
 #define TIF_SINGLESTEP		4	/* restore singlestep on return to user mode */
 #define TIF_RESTORE_SIGMASK	5	/* restore signal mask in do_signal() */
 #define TIF_POLLING_NRFLAG	16	/* true if poll_idle() is polling TIF_NEED_RESCHED */
-#define TIF_MEMDIE		17	/* OOM killer killed process */
+#define TIF_MEMDIE		17	/* is terminating due to OOM killer */
 #define TIF_FREEZE		18	/* freezing for suspend */
 
 #define _TIF_SYSCALL_TRACE	(1 << TIF_SYSCALL_TRACE)
diff --git a/arch/h8300/include/asm/thread_info.h b/arch/h8300/include/asm/thread_info.h
index 70e67e4..636b28e 100644
--- a/arch/h8300/include/asm/thread_info.h
+++ b/arch/h8300/include/asm/thread_info.h
@@ -87,7 +87,7 @@ static inline struct thread_info *current_thread_info(void)
 #define TIF_NEED_RESCHED	2	/* rescheduling necessary */
 #define TIF_POLLING_NRFLAG	3	/* true if poll_idle() is polling
 					   TIF_NEED_RESCHED */
-#define TIF_MEMDIE		4
+#define TIF_MEMDIE		4	/* is terminating due to OOM killer */
 #define TIF_RESTORE_SIGMASK	5	/* restore signal mask in do_signal() */
 #define TIF_NOTIFY_RESUME	6	/* callback before returning to user */
 #define TIF_FREEZE		16	/* is freezing for suspend */
diff --git a/arch/ia64/include/asm/thread_info.h b/arch/ia64/include/asm/thread_info.h
index 8ce2e38..fc8cbdb 100644
--- a/arch/ia64/include/asm/thread_info.h
+++ b/arch/ia64/include/asm/thread_info.h
@@ -102,7 +102,7 @@ struct thread_info {
 #define TIF_SINGLESTEP		4	/* restore singlestep on return to user mode */
 #define TIF_NOTIFY_RESUME	6	/* resumption notification requested */
 #define TIF_POLLING_NRFLAG	16	/* true if poll_idle() is polling TIF_NEED_RESCHED */
-#define TIF_MEMDIE		17
+#define TIF_MEMDIE		17	/* is terminating due to OOM killer */
 #define TIF_MCA_INIT		18	/* this task is processing MCA or INIT */
 #define TIF_DB_DISABLED		19	/* debug trap disabled for fsyscall */
 #define TIF_FREEZE		20	/* is freezing for suspend */
diff --git a/arch/m32r/include/asm/thread_info.h b/arch/m32r/include/asm/thread_info.h
index ed240b6..7655d07 100644
--- a/arch/m32r/include/asm/thread_info.h
+++ b/arch/m32r/include/asm/thread_info.h
@@ -142,7 +142,7 @@ static inline unsigned int get_thread_fault_code(void)
 #define TIF_RESTORE_SIGMASK	8	/* restore signal mask in do_signal() */
 #define TIF_USEDFPU		16	/* FPU was used by this task this quantum (SMP) */
 #define TIF_POLLING_NRFLAG	17	/* true if poll_idle() is polling TIF_NEED_RESCHED */
-#define TIF_MEMDIE		18	/* OOM killer killed process */
+#define TIF_MEMDIE		18	/* is terminating due to OOM killer */
 #define TIF_FREEZE		19	/* is freezing for suspend */
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
diff --git a/arch/m68k/include/asm/thread_info_mm.h b/arch/m68k/include/asm/thread_info_mm.h
index 67266c6..eab28f5 100644
--- a/arch/m68k/include/asm/thread_info_mm.h
+++ b/arch/m68k/include/asm/thread_info_mm.h
@@ -65,7 +65,7 @@ struct thread_info {
 #define TIF_NEED_RESCHED	7	/* rescheduling necessary */
 #define TIF_DELAYED_TRACE	14	/* single step a syscall */
 #define TIF_SYSCALL_TRACE	15	/* syscall trace active */
-#define TIF_MEMDIE		16
+#define TIF_MEMDIE		16	/* is terminating due to OOM killer */
 #define TIF_FREEZE		17	/* thread is freezing for suspend */
 
 #endif	/* _ASM_M68K_THREAD_INFO_H */
diff --git a/arch/m68k/include/asm/thread_info_no.h b/arch/m68k/include/asm/thread_info_no.h
index 884776f..26d17b2 100644
--- a/arch/m68k/include/asm/thread_info_no.h
+++ b/arch/m68k/include/asm/thread_info_no.h
@@ -85,7 +85,7 @@ static inline struct thread_info *current_thread_info(void)
 #define TIF_NEED_RESCHED	2	/* rescheduling necessary */
 #define TIF_POLLING_NRFLAG	3	/* true if poll_idle() is polling
 					   TIF_NEED_RESCHED */
-#define TIF_MEMDIE		4
+#define TIF_MEMDIE		4	/* is terminating due to OOM killer */
 #define TIF_FREEZE		16	/* is freezing for suspend */
 
 /* as above, but as bit values */
diff --git a/arch/microblaze/include/asm/thread_info.h b/arch/microblaze/include/asm/thread_info.h
index b2ca80f..eb392eb 100644
--- a/arch/microblaze/include/asm/thread_info.h
+++ b/arch/microblaze/include/asm/thread_info.h
@@ -122,7 +122,7 @@ static inline struct thread_info *current_thread_info(void)
 /* restore singlestep on return to user mode */
 #define TIF_SINGLESTEP		4
 #define TIF_IRET		5 /* return with iret */
-#define TIF_MEMDIE		6
+#define TIF_MEMDIE		6	/* is terminating due to OOM killer */
 #define TIF_SYSCALL_AUDIT	9       /* syscall auditing active */
 #define TIF_SECCOMP		10      /* secure computing */
 #define TIF_FREEZE		14	/* Freezing for suspend */
diff --git a/arch/mips/include/asm/thread_info.h b/arch/mips/include/asm/thread_info.h
index 845da21..bd4d48e 100644
--- a/arch/mips/include/asm/thread_info.h
+++ b/arch/mips/include/asm/thread_info.h
@@ -112,7 +112,7 @@ register struct thread_info *__current_thread_info __asm__("$28");
 #define TIF_RESTORE_SIGMASK	9	/* restore signal mask in do_signal() */
 #define TIF_USEDFPU		16	/* FPU was used by this task this quantum (SMP) */
 #define TIF_POLLING_NRFLAG	17	/* true if poll_idle() is polling TIF_NEED_RESCHED */
-#define TIF_MEMDIE		18
+#define TIF_MEMDIE		18	/* is terminating due to OOM killer */
 #define TIF_FREEZE		19
 #define TIF_FIXADE		20	/* Fix address errors in software */
 #define TIF_LOGADE		21	/* Log address errors to syslog */
diff --git a/arch/mn10300/include/asm/thread_info.h b/arch/mn10300/include/asm/thread_info.h
index 58d64f8..18c6884 100644
--- a/arch/mn10300/include/asm/thread_info.h
+++ b/arch/mn10300/include/asm/thread_info.h
@@ -148,7 +148,7 @@ static inline unsigned long current_stack_pointer(void)
 #define TIF_SINGLESTEP		4	/* restore singlestep on return to user mode */
 #define TIF_RESTORE_SIGMASK	5	/* restore signal mask in do_signal() */
 #define TIF_POLLING_NRFLAG	16	/* true if poll_idle() is polling TIF_NEED_RESCHED */
-#define TIF_MEMDIE		17	/* OOM killer killed process */
+#define TIF_MEMDIE		17	/* is terminating due to OOM killer */
 #define TIF_FREEZE		18	/* freezing for suspend */
 
 #define _TIF_SYSCALL_TRACE	+(1 << TIF_SYSCALL_TRACE)
diff --git a/arch/parisc/include/asm/thread_info.h b/arch/parisc/include/asm/thread_info.h
index 7ecc103..834a9cc 100644
--- a/arch/parisc/include/asm/thread_info.h
+++ b/arch/parisc/include/asm/thread_info.h
@@ -56,7 +56,7 @@ struct thread_info {
 #define TIF_NEED_RESCHED	2	/* rescheduling necessary */
 #define TIF_POLLING_NRFLAG	3	/* true if poll_idle() is polling TIF_NEED_RESCHED */
 #define TIF_32BIT               4       /* 32 bit binary */
-#define TIF_MEMDIE		5
+#define TIF_MEMDIE		5	/* is terminating due to OOM killer */
 #define TIF_RESTORE_SIGMASK	6	/* restore saved signal mask */
 #define TIF_FREEZE		7	/* is freezing for suspend */
 #define TIF_NOTIFY_RESUME	8	/* callback before returning to user */
diff --git a/arch/powerpc/include/asm/thread_info.h b/arch/powerpc/include/asm/thread_info.h
index aa9d383..bded9a8 100644
--- a/arch/powerpc/include/asm/thread_info.h
+++ b/arch/powerpc/include/asm/thread_info.h
@@ -104,7 +104,7 @@ static inline struct thread_info *current_thread_info(void)
 #define TIF_PERFMON_CTXSW	6	/* perfmon needs ctxsw calls */
 #define TIF_SYSCALL_AUDIT	7	/* syscall auditing active */
 #define TIF_SINGLESTEP		8	/* singlestepping active */
-#define TIF_MEMDIE		9
+#define TIF_MEMDIE		9	/* is terminating due to OOM killer */
 #define TIF_SECCOMP		10	/* secure computing */
 #define TIF_RESTOREALL		11	/* Restore all regs (implies NOERROR) */
 #define TIF_NOERROR		12	/* Force successful syscall return */
diff --git a/arch/s390/include/asm/thread_info.h b/arch/s390/include/asm/thread_info.h
index 34f0873..8580139 100644
--- a/arch/s390/include/asm/thread_info.h
+++ b/arch/s390/include/asm/thread_info.h
@@ -96,7 +96,7 @@ static inline struct thread_info *current_thread_info(void)
 #define TIF_POLLING_NRFLAG	16	/* true if poll_idle() is polling
 					   TIF_NEED_RESCHED */
 #define TIF_31BIT		17	/* 32bit process */
-#define TIF_MEMDIE		18
+#define TIF_MEMDIE		18	/* is terminating due to OOM killer */
 #define TIF_RESTORE_SIGMASK	19	/* restore signal mask in do_signal() */
 #define TIF_FREEZE		20	/* thread is freezing for suspend */
 
diff --git a/arch/score/include/asm/thread_info.h b/arch/score/include/asm/thread_info.h
index 5593999..f058d33 100644
--- a/arch/score/include/asm/thread_info.h
+++ b/arch/score/include/asm/thread_info.h
@@ -92,7 +92,7 @@ register struct thread_info *__current_thread_info __asm__("r28");
 #define TIF_RESTORE_SIGMASK	9	/* restore signal mask in do_signal() */
 #define TIF_POLLING_NRFLAG	17	/* true if poll_idle() is polling
 						 TIF_NEED_RESCHED */
-#define TIF_MEMDIE		18
+#define TIF_MEMDIE		18	/* is terminating due to OOM killer */
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
diff --git a/arch/sh/include/asm/thread_info.h b/arch/sh/include/asm/thread_info.h
index 55a36fe..d1a3140 100644
--- a/arch/sh/include/asm/thread_info.h
+++ b/arch/sh/include/asm/thread_info.h
@@ -121,7 +121,7 @@ extern void init_thread_xstate(void);
 #define TIF_NOTIFY_RESUME	7	/* callback before returning to user */
 #define TIF_SYSCALL_TRACEPOINT	8	/* for ftrace syscall instrumentation */
 #define TIF_POLLING_NRFLAG	17	/* true if poll_idle() is polling TIF_NEED_RESCHED */
-#define TIF_MEMDIE		18
+#define TIF_MEMDIE		18	/* is terminating due to OOM killer */
 #define TIF_FREEZE		19	/* Freezing for suspend */
 
 #define _TIF_SYSCALL_TRACE	(1 << TIF_SYSCALL_TRACE)
diff --git a/arch/sparc/include/asm/thread_info_32.h b/arch/sparc/include/asm/thread_info_32.h
index 844d73a..6a330f7 100644
--- a/arch/sparc/include/asm/thread_info_32.h
+++ b/arch/sparc/include/asm/thread_info_32.h
@@ -132,7 +132,7 @@ BTFIXUPDEF_CALL(void, free_thread_info, struct thread_info *)
 					 * this quantum (SMP) */
 #define TIF_POLLING_NRFLAG	9	/* true if poll_idle() is polling
 					 * TIF_NEED_RESCHED */
-#define TIF_MEMDIE		10
+#define TIF_MEMDIE		10	/* is terminating due to OOM killer */
 #define TIF_FREEZE		11	/* is freezing for suspend */
 
 /* as above, but as bit values */
diff --git a/arch/sparc/include/asm/thread_info_64.h b/arch/sparc/include/asm/thread_info_64.h
index 4827a3a..9c8dc20 100644
--- a/arch/sparc/include/asm/thread_info_64.h
+++ b/arch/sparc/include/asm/thread_info_64.h
@@ -223,7 +223,7 @@ register struct thread_info *current_thread_info_reg asm("g6");
  *       an immediate value in instructions such as andcc.
  */
 /* flag bit 12 is available */
-#define TIF_MEMDIE		13
+#define TIF_MEMDIE		13	/* is terminating due to OOM killer */
 #define TIF_POLLING_NRFLAG	14
 #define TIF_FREEZE		15	/* is freezing for suspend */
 
diff --git a/arch/um/include/asm/thread_info.h b/arch/um/include/asm/thread_info.h
index fd911f8..3db3d43 100644
--- a/arch/um/include/asm/thread_info.h
+++ b/arch/um/include/asm/thread_info.h
@@ -63,10 +63,9 @@ static inline struct thread_info *current_thread_info(void)
 #define TIF_SIGPENDING		1	/* signal pending */
 #define TIF_NEED_RESCHED	2	/* rescheduling necessary */
 #define TIF_POLLING_NRFLAG      3       /* true if poll_idle() is polling
-					 * TIF_NEED_RESCHED
-					 */
-#define TIF_RESTART_BLOCK 	4
-#define TIF_MEMDIE	 	5
+					 * TIF_NEED_RESCHED */
+#define TIF_RESTART_BLOCK	4
+#define TIF_MEMDIE		5	/* is terminating due to OOM killer */
 #define TIF_SYSCALL_AUDIT	6
 #define TIF_RESTORE_SIGMASK	7
 #define TIF_FREEZE		16	/* is freezing for suspend */
diff --git a/arch/x86/include/asm/thread_info.h b/arch/x86/include/asm/thread_info.h
index e0d2890..47ea26c 100644
--- a/arch/x86/include/asm/thread_info.h
+++ b/arch/x86/include/asm/thread_info.h
@@ -87,7 +87,7 @@ struct thread_info {
 #define TIF_NOTSC		16	/* TSC is not accessible in userland */
 #define TIF_IA32		17	/* 32bit process */
 #define TIF_FORK		18	/* ret_from_fork */
-#define TIF_MEMDIE		20
+#define TIF_MEMDIE		20	/* is terminating due to OOM killer */
 #define TIF_DEBUG		21	/* uses debug registers */
 #define TIF_IO_BITMAP		22	/* uses I/O bitmap */
 #define TIF_FREEZE		23	/* is freezing for suspend */
diff --git a/arch/xtensa/include/asm/thread_info.h b/arch/xtensa/include/asm/thread_info.h
index 1316564..916a802 100644
--- a/arch/xtensa/include/asm/thread_info.h
+++ b/arch/xtensa/include/asm/thread_info.h
@@ -129,7 +129,7 @@ static inline struct thread_info *current_thread_info(void)
 #define TIF_NEED_RESCHED	2	/* rescheduling necessary */
 #define TIF_SINGLESTEP		3	/* restore singlestep on return to user mode */
 #define TIF_IRET		4	/* return with iret */
-#define TIF_MEMDIE		5
+#define TIF_MEMDIE		5	/* is terminating due to OOM killer */
 #define TIF_RESTORE_SIGMASK	6	/* restore signal mask in do_signal() */
 #define TIF_POLLING_NRFLAG	16	/* true if poll_idle() is polling TIF_NEED_RESCHED */
 #define TIF_FREEZE		17	/* is freezing for suspend */

--Apple-Mail-13--872443955--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
