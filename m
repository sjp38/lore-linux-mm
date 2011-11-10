Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 143C16B0070
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 14:04:10 -0500 (EST)
Received: from /spool/local
	by e28smtp09.in.ibm.com with XMail ESMTP
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 11 Nov 2011 00:33:55 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAAJ3pKQ4079848
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 00:33:51 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAAJ3oZH013475
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 06:03:51 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 11 Nov 2011 00:08:55 +0530
Message-Id: <20111110183855.11361.59504.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20111110183725.11361.57827.sendpatchset@srdronam.in.ibm.com>
References: <20111110183725.11361.57827.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v6 3.2-rc1 7/28]   Uprobes: uprobes arch info
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>


Introduce per uprobe arch info structure.
Used to store arch specific details. For example: details to handle
Rip relative instructions in X86_64.

Signed-off-by: Jim Keniston <jkenisto@us.ibm.com>
Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 include/linux/uprobes.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index dd308fa..44f28dc 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -29,7 +29,7 @@ struct vm_area_struct;
 #ifdef CONFIG_ARCH_SUPPORTS_UPROBES
 #include <asm/uprobes.h>
 #else
-
+struct uprobe_arch_info {};
 #define MAX_UINSN_BYTES 4
 #endif
 
@@ -60,6 +60,7 @@ struct uprobe {
 	atomic_t		ref;
 	struct rw_semaphore	consumer_rwsem;
 	struct list_head	pending_list;
+	struct uprobe_arch_info arch_info;
 	struct uprobe_consumer	*consumers;
 	struct inode		*inode;		/* Also hold a ref to inode */
 	loff_t			offset;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
