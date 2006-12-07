Message-Id: <20061207162737.206146000@chello.nl>
References: <20061207161800.426936000@chello.nl>
Date: Thu, 07 Dec 2006 17:18:13 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 13/16] atomic_ulong_t
Content-Disposition: inline; filename=atomic_ulong_t.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

provide an unsigned long atomic type.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/asm-generic/atomic.h |   45 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 45 insertions(+)

Index: linux-2.6-rt/include/asm-generic/atomic.h
===================================================================
--- linux-2.6-rt.orig/include/asm-generic/atomic.h	2006-12-02 17:42:16.000000000 +0100
+++ linux-2.6-rt/include/asm-generic/atomic.h	2006-12-02 17:46:09.000000000 +0100
@@ -114,4 +114,49 @@ static inline void atomic_long_sub(long 
 }
 
 #endif
+
+typedef atomic_long_t atomic_ulong_t;
+
+#define ATOMIC_ULONG_INIT(i)	ATOMIC_LONG_INIT(i)
+static inline unsigned long atomic_ulong_read(atomic_ulong_t *l)
+{
+	atomic_long_t *v = (atomic_long_t *)l;
+
+	return (unsigned long)atomic_long_read(v);
+}
+
+static inline void atomic_ulong_set(atomic_ulong_t *l, unsigned long i)
+{
+	atomic_long_t *v = (atomic_long_t *)l;
+
+	atomic_long_set(v, i);
+}
+
+static inline void atomic_ulong_inc(atomic_ulong_t *l)
+{
+	atomic_long_t *v = (atomic_long_t *)l;
+
+	atomic_long_inc(v);
+}
+
+static inline void atomic_ulong_dec(atomic_ulong_t *l)
+{
+	atomic_long_t *v = (atomic_long_t *)l;
+
+	atomic_long_dec(v);
+}
+
+static inline void atomic_ulong_add(unsigned long i, atomic_ulong_t *l)
+{
+	atomic_long_t *v = (atomic_long_t *)l;
+
+	atomic_long_add(i, v);
+}
+
+static inline void atomic_ulong_sub(unsigned long i, atomic_ulong_t *l)
+{
+	atomic_long_t *v = (atomic_long_t *)l;
+
+	atomic_long_sub(i, v);
+}
 #endif

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
