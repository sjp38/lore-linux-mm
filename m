Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5E7596B0096
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 11:15:29 -0500 (EST)
From: Dan Smith <danms@us.ibm.com>
Subject: [PATCH 15/19] c/r: introduce method '->checkpoint()' in struct vm_operations_struct
Date: Tue, 14 Dec 2010 08:15:03 -0800
Message-Id: <1292343307-7870-15-git-send-email-danms@us.ibm.com>
In-Reply-To: <1292343307-7870-1-git-send-email-danms@us.ibm.com>
References: <1292343307-7870-1-git-send-email-danms@us.ibm.com>
Sender: owner-linux-mm@kvack.org
To: danms@us.ibm.com
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

From: Oren Laadan <orenl@cs.columbia.edu>

Changelog[v17]
  - Forward-declare 'ckpt_ctx et-al, don't use checkpoint_types.h

Cc: linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org
Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
---
 include/linux/mm.h |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 721f451..fcd60ba 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -20,6 +20,8 @@ struct anon_vma;
 struct file_ra_state;
 struct user_struct;
 struct writeback_control;
+struct rlimit;
+struct ckpt_ctx;
 
 #ifndef CONFIG_DISCONTIGMEM          /* Don't use mapnrs, do it properly */
 extern unsigned long max_mapnr;
@@ -229,6 +231,9 @@ struct vm_operations_struct {
 	int (*migrate)(struct vm_area_struct *vma, const nodemask_t *from,
 		const nodemask_t *to, unsigned long flags);
 #endif
+#ifdef CONFIG_CHECKPOINT
+	int (*checkpoint)(struct ckpt_ctx *ctx, struct vm_area_struct *vma);
+#endif
 };
 
 struct mmu_gather;
-- 
1.7.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
