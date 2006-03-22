From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Message-Id: <20060322223511.12658.80845.sendpatchset@twins.localnet>
In-Reply-To: <20060322223107.12658.14997.sendpatchset@twins.localnet>
References: <20060322223107.12658.14997.sendpatchset@twins.localnet>
Subject: [PATCH 24/34] mm: sum_cpu_var.patch
Date: Wed, 22 Mar 2006 23:35:43 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Bob Picco <bob.picco@hp.com>, Andrew Morton <akpm@osdl.org>, IWAMOTO Toshihiro <iwamoto@valinux.co.jp>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <christoph@lameter.com>, Wu Fengguang <wfg@mail.ustc.edu.cn>, Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@osdl.org>, Rik van Riel <riel@redhat.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Much used per_cpu op by the additional policies.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>

---

 include/linux/percpu.h |    5 +++++
 1 file changed, 5 insertions(+)

Index: linux-2.6/include/linux/percpu.h
===================================================================
--- linux-2.6.orig/include/linux/percpu.h	2006-03-13 20:38:20.000000000 +0100
+++ linux-2.6/include/linux/percpu.h	2006-03-13 20:45:24.000000000 +0100
@@ -15,6 +15,11 @@
 #define get_cpu_var(var) (*({ preempt_disable(); &__get_cpu_var(var); }))
 #define put_cpu_var(var) preempt_enable()
 
+#define __sum_cpu_var(type, var) ({ __typeof__(type) sum = 0; \
+                                 int cpu; \
+                                 for_each_cpu(cpu) sum += per_cpu(var, cpu); \
+                                 sum; })
+
 #ifdef CONFIG_SMP
 
 struct percpu_data {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
