Subject: Re: 2.6.1-mm3
References: <20040114014846.78e1a31b.akpm@osdl.org>
From: Jes Sorensen <jes@wildopensource.com>
Date: 14 Jan 2004 07:27:34 -0500
In-Reply-To: <20040114014846.78e1a31b.akpm@osdl.org>
Message-ID: <yq04quyr9zd.fsf@wildopensource.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jesse Barnes <jbarnes@sgi.com>
List-ID: <linux-mm.kvack.org>

Hi Andrew,

Tiny patch to make -mm3 compile on an NUMA box with NR_CPUS >
BITS_PER_LONG.

Cheers,
Jes

--- old/kernel/sched.c~	Wed Jan 14 02:59:53 2004
+++ new/kernel/sched.c	Wed Jan 14 03:18:28 2004
@@ -3249,7 +3249,7 @@
 		for_each_cpu_mask(j, node->cpumask) {
 			struct sched_group *cpu = &sched_group_cpus[j];
 
-			cpu->cpumask = CPU_MASK_NONE;
+			cpus_clear(cpu->cpumask);
 			cpu_set(j, cpu->cpumask);
 
 			printk(KERN_INFO "CPU%d\n", j);
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
