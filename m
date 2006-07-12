From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 12 Jul 2006 16:42:05 +0200
Message-Id: <20060712144205.16998.87419.sendpatchset@lappy>
In-Reply-To: <20060712143659.16998.6444.sendpatchset@lappy>
References: <20060712143659.16998.6444.sendpatchset@lappy>
Subject: [PATCH 26/39] sum_cpu_var
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Much used per_cpu op by the additional policies.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>

 include/linux/percpu.h |    5 +++++
 1 file changed, 5 insertions(+)

Index: linux-2.6/include/linux/percpu.h
===================================================================
--- linux-2.6.orig/include/linux/percpu.h	2006-06-12 06:51:08.000000000 +0200
+++ linux-2.6/include/linux/percpu.h	2006-07-12 16:09:19.000000000 +0200
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
