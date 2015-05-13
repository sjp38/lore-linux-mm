Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 1C6786B0073
	for <linux-mm@kvack.org>; Wed, 13 May 2015 01:31:00 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so38991271pac.1
        for <linux-mm@kvack.org>; Tue, 12 May 2015 22:30:59 -0700 (PDT)
Received: from mail.sfc.wide.ad.jp (shonan.sfc.wide.ad.jp. [203.178.142.130])
        by mx.google.com with ESMTPS id pa10si25563886pdb.114.2015.05.12.22.30.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 May 2015 22:30:58 -0700 (PDT)
From: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
Subject: [PATCH v5 08/10] lib: auxiliary files for auto-generated asm-generic files of libos
Date: Wed, 13 May 2015 07:28:39 +0200
Message-Id: <1431494921-24746-9-git-send-email-tazaki@sfc.wide.ad.jp>
In-Reply-To: <1431494921-24746-1-git-send-email-tazaki@sfc.wide.ad.jp>
References: <1430103618-10832-1-git-send-email-tazaki@sfc.wide.ad.jp>
 <1431494921-24746-1-git-send-email-tazaki@sfc.wide.ad.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org
Cc: Hajime Tazaki <tazaki@sfc.wide.ad.jp>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Christoph Lameter <cl@linux.com>, Jekka Enberg <penberg@kernel.org>, Javid Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jndrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Rusty Russell <rusty@rustcorp.com.au>, Ryo Nakamura <upa@haeena.net>, Christoph Paasch <christoph.paasch@gmail.com>, Mathieu Lacage <mathieu.lacage@gmail.com>, libos-nuse@googlegroups.com

these files works as stubs in order to transparently run the other
kernel part (e.g., net/) on libos environment.

Signed-off-by: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
---
 arch/lib/include/asm/Kbuild           | 57 +++++++++++++++++++++++++++++++++
 arch/lib/include/asm/atomic.h         | 59 +++++++++++++++++++++++++++++++++++
 arch/lib/include/asm/barrier.h        |  8 +++++
 arch/lib/include/asm/bitsperlong.h    | 16 ++++++++++
 arch/lib/include/asm/current.h        |  7 +++++
 arch/lib/include/asm/elf.h            | 10 ++++++
 arch/lib/include/asm/hardirq.h        |  8 +++++
 arch/lib/include/asm/page.h           | 14 +++++++++
 arch/lib/include/asm/pgtable.h        | 30 ++++++++++++++++++
 arch/lib/include/asm/processor.h      | 19 +++++++++++
 arch/lib/include/asm/ptrace.h         |  4 +++
 arch/lib/include/asm/segment.h        |  6 ++++
 arch/lib/include/asm/sembuf.h         |  4 +++
 arch/lib/include/asm/shmbuf.h         |  4 +++
 arch/lib/include/asm/shmparam.h       |  4 +++
 arch/lib/include/asm/sigcontext.h     |  6 ++++
 arch/lib/include/asm/stat.h           |  4 +++
 arch/lib/include/asm/statfs.h         |  4 +++
 arch/lib/include/asm/swab.h           |  7 +++++
 arch/lib/include/asm/thread_info.h    | 36 +++++++++++++++++++++
 arch/lib/include/asm/uaccess.h        | 14 +++++++++
 arch/lib/include/asm/unistd.h         |  4 +++
 arch/lib/include/uapi/asm/byteorder.h |  6 ++++
 23 files changed, 331 insertions(+)
 create mode 100644 arch/lib/include/asm/Kbuild
 create mode 100644 arch/lib/include/asm/atomic.h
 create mode 100644 arch/lib/include/asm/barrier.h
 create mode 100644 arch/lib/include/asm/bitsperlong.h
 create mode 100644 arch/lib/include/asm/current.h
 create mode 100644 arch/lib/include/asm/elf.h
 create mode 100644 arch/lib/include/asm/hardirq.h
 create mode 100644 arch/lib/include/asm/page.h
 create mode 100644 arch/lib/include/asm/pgtable.h
 create mode 100644 arch/lib/include/asm/processor.h
 create mode 100644 arch/lib/include/asm/ptrace.h
 create mode 100644 arch/lib/include/asm/segment.h
 create mode 100644 arch/lib/include/asm/sembuf.h
 create mode 100644 arch/lib/include/asm/shmbuf.h
 create mode 100644 arch/lib/include/asm/shmparam.h
 create mode 100644 arch/lib/include/asm/sigcontext.h
 create mode 100644 arch/lib/include/asm/stat.h
 create mode 100644 arch/lib/include/asm/statfs.h
 create mode 100644 arch/lib/include/asm/swab.h
 create mode 100644 arch/lib/include/asm/thread_info.h
 create mode 100644 arch/lib/include/asm/uaccess.h
 create mode 100644 arch/lib/include/asm/unistd.h
 create mode 100644 arch/lib/include/uapi/asm/byteorder.h

diff --git a/arch/lib/include/asm/Kbuild b/arch/lib/include/asm/Kbuild
new file mode 100644
index 0000000..c647b1c
--- /dev/null
+++ b/arch/lib/include/asm/Kbuild
@@ -0,0 +1,57 @@
+generic-y += auxvec.h
+generic-y += bitops.h
+generic-y += bug.h
+generic-y += cache.h
+generic-y += cacheflush.h
+generic-y += checksum.h
+generic-y += cputime.h
+generic-y += cmpxchg.h
+generic-y += delay.h
+generic-y += device.h
+generic-y += div64.h
+generic-y += dma.h
+generic-y += exec.h
+generic-y += emergency-restart.h
+generic-y += errno.h
+generic-y += fcntl.h
+generic-y += ftrace.h
+generic-y += io.h
+generic-y += ioctl.h
+generic-y += ioctls.h
+generic-y += ipcbuf.h
+generic-y += irq.h
+generic-y += irqflags.h
+generic-y += irq_regs.h
+generic-y += kdebug.h
+generic-y += kmap_types.h
+generic-y += linkage.h
+generic-y += local.h
+generic-y += mcs_spinlock.h
+generic-y += mman.h
+generic-y += mmu.h
+generic-y += mmu_context.h
+generic-y += module.h
+generic-y += mutex.h
+generic-y += param.h
+generic-y += pci.h
+generic-y += percpu.h
+generic-y += poll.h
+generic-y += posix_types.h
+generic-y += preempt.h
+generic-y += resource.h
+generic-y += scatterlist.h
+generic-y += sections.h
+generic-y += setup.h
+generic-y += signal.h
+generic-y += siginfo.h
+generic-y += socket.h
+generic-y += sockios.h
+generic-y += string.h
+generic-y += termbits.h
+generic-y += termios.h
+generic-y += timex.h
+generic-y += tlbflush.h
+generic-y += types.h
+generic-y += topology.h
+generic-y += trace_clock.h
+generic-y += unaligned.h
diff --git a/arch/lib/include/asm/atomic.h b/arch/lib/include/asm/atomic.h
new file mode 100644
index 0000000..444a953
--- /dev/null
+++ b/arch/lib/include/asm/atomic.h
@@ -0,0 +1,59 @@
+#ifndef _ASM_SIM_ATOMIC_H
+#define _ASM_SIM_ATOMIC_H
+
+#include <linux/types.h>
+#include <asm-generic/cmpxchg.h>
+
+#if !defined(CONFIG_64BIT)
+typedef struct {
+	volatile long long counter;
+} atomic64_t;
+#endif
+
+#define ATOMIC64_INIT(i) { (i) }
+
+#define atomic64_read(v)        (*(volatile long *)&(v)->counter)
+void atomic64_add(long i, atomic64_t *v);
+static inline void atomic64_sub(long i, atomic64_t *v)
+{
+	v->counter -= i;
+}
+static inline void atomic64_inc(atomic64_t *v)
+{
+	v->counter++;
+}
+int atomic64_sub_and_test(long i, atomic64_t *v);
+#define atomic64_dec(v)			atomic64_sub(1LL, (v))
+int atomic64_dec_and_test(atomic64_t *v);
+int atomic64_inc_and_test(atomic64_t *v);
+int atomic64_add_negative(long i, atomic64_t *v);
+/* long atomic64_add_return(long i, atomic64_t *v); */
+static inline long atomic64_add_return(long i, atomic64_t *v)
+{
+	v->counter += i;
+	return v->counter;
+}
+static inline void atomic64_set(atomic64_t *v, long i)
+{
+	v->counter = i;
+}
+long atomic64_sub_return(long i, atomic64_t *v);
+#define atomic64_inc_return(v)  (atomic64_add_return(1, (v)))
+#define atomic64_dec_return(v)  (atomic64_sub_return(1, (v)))
+static inline long atomic64_cmpxchg(atomic64_t *v, long old, long new)
+{
+	long long val;
+
+	val = v->counter;
+	if (val == old)
+		v->counter = new;
+	return val;
+}
+long atomic64_xchg(atomic64_t *v, long new);
+int atomic64_add_unless(atomic64_t *v, long a, long u);
+int atomic64_inc_is_not_zero(atomic64_t *v);
+#define atomic64_inc_not_zero(v) 	atomic64_add_unless((v), 1LL, 0LL)
+
+#include <asm-generic/atomic.h>
+
+#endif /* _ASM_SIM_ATOMIC_H */
diff --git a/arch/lib/include/asm/barrier.h b/arch/lib/include/asm/barrier.h
new file mode 100644
index 0000000..47adcc6
--- /dev/null
+++ b/arch/lib/include/asm/barrier.h
@@ -0,0 +1,8 @@
+#include <asm-generic/barrier.h>
+
+#undef smp_store_release
+#define smp_store_release(p, v)						\
+	do {								\
+		smp_mb();						\
+		ACCESS_ONCE(*p) = (v);					\
+	} while (0)
diff --git a/arch/lib/include/asm/bitsperlong.h b/arch/lib/include/asm/bitsperlong.h
new file mode 100644
index 0000000..9890ba9
--- /dev/null
+++ b/arch/lib/include/asm/bitsperlong.h
@@ -0,0 +1,16 @@
+#ifndef _ASM_SIM_BITSPERLONG_H
+#define _ASM_SIM_BITSPERLONG_H
+
+#ifdef CONFIG_64BIT
+#define BITS_PER_LONG 64
+#else
+#define BITS_PER_LONG 32
+#endif /* CONFIG_64BIT */
+
+#define __BITS_PER_LONG BITS_PER_LONG
+
+#ifndef BITS_PER_LONG_LONG
+#define BITS_PER_LONG_LONG 64
+#endif
+
+#endif /* _ASM_SIM_BITSPERLONG_H */
diff --git a/arch/lib/include/asm/current.h b/arch/lib/include/asm/current.h
new file mode 100644
index 0000000..62489cd
--- /dev/null
+++ b/arch/lib/include/asm/current.h
@@ -0,0 +1,7 @@
+#ifndef _ASM_SIM_CURRENT_H
+#define _ASM_SIM_CURRENT_H
+
+struct task_struct *get_current(void);
+#define current get_current()
+
+#endif /* _ASM_SIM_CURRENT_H */
diff --git a/arch/lib/include/asm/elf.h b/arch/lib/include/asm/elf.h
new file mode 100644
index 0000000..a7396c9
--- /dev/null
+++ b/arch/lib/include/asm/elf.h
@@ -0,0 +1,10 @@
+#ifndef _ASM_SIM_ELF_H
+#define _ASM_SIM_ELF_H
+
+#if defined(CONFIG_64BIT)
+#define ELF_CLASS ELFCLASS64
+#else
+#define ELF_CLASS ELFCLASS32
+#endif
+
+#endif /* _ASM_SIM_ELF_H */
diff --git a/arch/lib/include/asm/hardirq.h b/arch/lib/include/asm/hardirq.h
new file mode 100644
index 0000000..47d47f9
--- /dev/null
+++ b/arch/lib/include/asm/hardirq.h
@@ -0,0 +1,8 @@
+#ifndef _ASM_SIM_HARDIRQ_H
+#define _ASM_SIM_HARDIRQ_H
+
+extern unsigned int interrupt_pending;
+
+#define local_softirq_pending() (interrupt_pending)
+
+#endif /* _ASM_SIM_HARDIRQ_H */
diff --git a/arch/lib/include/asm/page.h b/arch/lib/include/asm/page.h
new file mode 100644
index 0000000..8c0aa74
--- /dev/null
+++ b/arch/lib/include/asm/page.h
@@ -0,0 +1,14 @@
+#ifndef _ASM_SIM_PAGE_H
+#define _ASM_SIM_PAGE_H
+
+typedef struct {} pud_t;
+
+#define THREAD_ORDER    1
+#define THREAD_SIZE  (PAGE_SIZE << THREAD_ORDER)
+
+#define WANT_PAGE_VIRTUAL 1
+
+#include <asm-generic/page.h>
+#include <asm-generic/getorder.h>
+
+#endif /* _ASM_SIM_PAGE_H */
diff --git a/arch/lib/include/asm/pgtable.h b/arch/lib/include/asm/pgtable.h
new file mode 100644
index 0000000..ce599c8
--- /dev/null
+++ b/arch/lib/include/asm/pgtable.h
@@ -0,0 +1,30 @@
+#ifndef _ASM_SIM_PGTABLE_H
+#define _ASM_SIM_PGTABLE_H
+
+#define PAGE_KERNEL ((pgprot_t) {0 })
+
+#define arch_start_context_switch(prev) do {} while (0)
+
+#define kern_addr_valid(addr)(1)
+#define pte_file(pte)(1)
+/* Encode and de-code a swap entry */
+#define __swp_type(x)                   (((x).val >> 5) & 0x1f)
+#define __swp_offset(x)                 ((x).val >> 11)
+#define __swp_entry(type, offset) \
+	((swp_entry_t) {((type) << 5) | ((offset) << 11) })
+#define __pte_to_swp_entry(pte)         ((swp_entry_t) {pte_val((pte)) })
+#define __swp_entry_to_pte(x)           ((pte_t) {(x).val })
+#define pmd_page(pmd) (struct page *)(pmd_val(pmd) & PAGE_MASK)
+#define pgtable_cache_init()   do { } while (0)
+
+static inline int pte_swp_soft_dirty(pte_t pte)
+{
+	return 0;
+}
+
+static inline pte_t pte_swp_clear_soft_dirty(pte_t pte)
+{
+	return pte;
+}
+
+#endif /* _ASM_SIM_PGTABLE_H */
diff --git a/arch/lib/include/asm/processor.h b/arch/lib/include/asm/processor.h
new file mode 100644
index 0000000..b673ee0
--- /dev/null
+++ b/arch/lib/include/asm/processor.h
@@ -0,0 +1,19 @@
+#ifndef _ASM_SIM_PROCESSOR_H
+#define _ASM_SIM_PROCESSOR_H
+
+struct thread_struct {};
+
+#define cpu_relax()
+#define cpu_relax_lowlatency() cpu_relax()
+#define KSTK_ESP(tsk)	(0)
+
+void *current_text_addr(void);
+
+#define TASK_SIZE ((~(long)0))
+
+#define thread_saved_pc(x) (unsigned long)0
+#define task_pt_regs(t) NULL
+
+int kernel_thread(int (*fn)(void *), void *arg, unsigned long flags);
+
+#endif /* _ASM_SIM_PROCESSOR_H */
diff --git a/arch/lib/include/asm/ptrace.h b/arch/lib/include/asm/ptrace.h
new file mode 100644
index 0000000..ddd9708
--- /dev/null
+++ b/arch/lib/include/asm/ptrace.h
@@ -0,0 +1,4 @@
+#ifndef _ASM_SIM_PTRACE_H
+#define _ASM_SIM_PTRACE_H
+
+#endif /* _ASM_SIM_PTRACE_H */
diff --git a/arch/lib/include/asm/segment.h b/arch/lib/include/asm/segment.h
new file mode 100644
index 0000000..e056922
--- /dev/null
+++ b/arch/lib/include/asm/segment.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_SIM_SEGMENT_H
+#define _ASM_SIM_SEGMENT_H
+
+typedef struct { int seg; } mm_segment_t;
+
+#endif /* _ASM_SIM_SEGMENT_H */
diff --git a/arch/lib/include/asm/sembuf.h b/arch/lib/include/asm/sembuf.h
new file mode 100644
index 0000000..d64927b
--- /dev/null
+++ b/arch/lib/include/asm/sembuf.h
@@ -0,0 +1,4 @@
+#ifndef _ASM_SIM_SEMBUF_H
+#define _ASM_SIM_SEMBUF_H
+
+#endif /* _ASM_SIM_SEMBUF_H */
diff --git a/arch/lib/include/asm/shmbuf.h b/arch/lib/include/asm/shmbuf.h
new file mode 100644
index 0000000..42d0a71
--- /dev/null
+++ b/arch/lib/include/asm/shmbuf.h
@@ -0,0 +1,4 @@
+#ifndef _ASM_SIM_SHMBUF_H
+#define _ASM_SIM_SHMBUF_H
+
+#endif /* _ASM_SIM_SHMBUF_H */
diff --git a/arch/lib/include/asm/shmparam.h b/arch/lib/include/asm/shmparam.h
new file mode 100644
index 0000000..3410f1b
--- /dev/null
+++ b/arch/lib/include/asm/shmparam.h
@@ -0,0 +1,4 @@
+#ifndef _ASM_SIM_SHMPARAM_H
+#define _ASM_SIM_SHMPARAM_H
+
+#endif /* _ASM_SIM_SHMPARAM_H */
diff --git a/arch/lib/include/asm/sigcontext.h b/arch/lib/include/asm/sigcontext.h
new file mode 100644
index 0000000..230b4b5
--- /dev/null
+++ b/arch/lib/include/asm/sigcontext.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_SIM_SIGCONTEXT_H
+#define _ASM_SIM_SIGCONTEXT_H
+
+struct sigcontext {};
+
+#endif /* _ASM_SIM_SIGCONTEXT_H */
diff --git a/arch/lib/include/asm/stat.h b/arch/lib/include/asm/stat.h
new file mode 100644
index 0000000..80fa2cb
--- /dev/null
+++ b/arch/lib/include/asm/stat.h
@@ -0,0 +1,4 @@
+#ifndef _ASM_SIM_STAT_H
+#define _ASM_SIM_STAT_H
+
+#endif /* _ASM_SIM_STAT_H */
diff --git a/arch/lib/include/asm/statfs.h b/arch/lib/include/asm/statfs.h
new file mode 100644
index 0000000..881ce51
--- /dev/null
+++ b/arch/lib/include/asm/statfs.h
@@ -0,0 +1,4 @@
+#ifndef _ASM_SIM_STATFS_H
+#define _ASM_SIM_STATFS_H
+
+#endif /* _ASM_SIM_STATFS_H */
diff --git a/arch/lib/include/asm/swab.h b/arch/lib/include/asm/swab.h
new file mode 100644
index 0000000..d81376a
--- /dev/null
+++ b/arch/lib/include/asm/swab.h
@@ -0,0 +1,7 @@
+#ifndef _ASM_SIM_SWAB_H
+#define _ASM_SIM_SWAB_H
+
+#include <linux/types.h>
+
+
+#endif /* _ASM_SIM_SWAB_H */
diff --git a/arch/lib/include/asm/thread_info.h b/arch/lib/include/asm/thread_info.h
new file mode 100644
index 0000000..ec316c6
--- /dev/null
+++ b/arch/lib/include/asm/thread_info.h
@@ -0,0 +1,36 @@
+#ifndef _ASM_SIM_THREAD_INFO_H
+#define _ASM_SIM_THREAD_INFO_H
+
+#define TIF_NEED_RESCHED 1
+#define TIF_SIGPENDING 2
+#define TIF_MEMDIE 5
+
+struct thread_info {
+	__u32 flags;
+	int preempt_count;
+	struct task_struct *task;
+	struct restart_block restart_block;
+};
+
+struct thread_info *current_thread_info(void);
+struct thread_info *alloc_thread_info(struct task_struct *task);
+void free_thread_info(struct thread_info *ti);
+
+#define TS_RESTORE_SIGMASK      0x0008  /* restore signal mask in do_signal() */
+#define HAVE_SET_RESTORE_SIGMASK        1
+static inline void set_restore_sigmask(void)
+{
+}
+static inline void clear_restore_sigmask(void)
+{
+}
+static inline bool test_restore_sigmask(void)
+{
+	return true;
+}
+static inline bool test_and_clear_restore_sigmask(void)
+{
+	return true;
+}
+
+#endif /* _ASM_SIM_THREAD_INFO_H */
diff --git a/arch/lib/include/asm/uaccess.h b/arch/lib/include/asm/uaccess.h
new file mode 100644
index 0000000..74f973b
--- /dev/null
+++ b/arch/lib/include/asm/uaccess.h
@@ -0,0 +1,14 @@
+#ifndef _ASM_SIM_UACCESS_H
+#define _ASM_SIM_UACCESS_H
+
+#define KERNEL_DS ((mm_segment_t) {0 })
+#define USER_DS ((mm_segment_t) {0 })
+#define get_fs() KERNEL_DS
+#define get_ds() USER_DS
+#define set_fs(x) do {} while ((x.seg) != (x.seg))
+
+#define __access_ok(addr, size) (1)
+
+#include <asm-generic/uaccess.h>
+
+#endif /* _ASM_SIM_UACCESS_H */
diff --git a/arch/lib/include/asm/unistd.h b/arch/lib/include/asm/unistd.h
new file mode 100644
index 0000000..6b482b4
--- /dev/null
+++ b/arch/lib/include/asm/unistd.h
@@ -0,0 +1,4 @@
+#ifndef _ASM_SIM_UNISTD_H
+#define _ASM_SIM_UNISTD_H
+
+#endif /* _ASM_SIM_UNISTD_H */
diff --git a/arch/lib/include/uapi/asm/byteorder.h b/arch/lib/include/uapi/asm/byteorder.h
new file mode 100644
index 0000000..b13a7a8
--- /dev/null
+++ b/arch/lib/include/uapi/asm/byteorder.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_X86_BYTEORDER_H
+#define _ASM_X86_BYTEORDER_H
+
+#include <linux/byteorder/little_endian.h>
+
+#endif /* _ASM_X86_BYTEORDER_H */
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
