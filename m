Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3707F6B0095
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 06:36:05 -0500 (EST)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 18 Nov 2011 11:30:58 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAIBWfTl2621690
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 22:32:41 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAIBZou9012981
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 22:35:54 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 18 Nov 2011 16:39:44 +0530
Message-Id: <20111118110944.10512.1822.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v7 3.2-rc2 16/30] uprobes: Introduce uprobe_task_arch_info structure.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>


uprobe_task_arch_info structure helps save and restore architecture
specific artifacts at the probehit/singlestep/original instruction
restore time.

Signed-off-by: Jim Keniston <jkenisto@us.ibm.com>
Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 include/linux/uprobes.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index 0882223..c1378a9 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -31,6 +31,7 @@ struct vm_area_struct;
 #else
 typedef u8 uprobe_opcode_t;
 struct uprobe_arch_info {};
+struct uprobe_task_arch_info {};	/* arch specific task info */
 #define MAX_UINSN_BYTES 4
 #endif
 
@@ -84,6 +85,7 @@ struct uprobe_task {
 	unsigned long vaddr;
 
 	enum uprobe_task_state state;
+	struct uprobe_task_arch_info tskinfo;
 
 	struct uprobe *active_uprobe;
 };

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
