Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 98F186B004A
	for <linux-mm@kvack.org>; Sat, 31 Mar 2012 05:29:37 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id q16so1494120bkw.14
        for <linux-mm@kvack.org>; Sat, 31 Mar 2012 02:29:37 -0700 (PDT)
Subject: [PATCH 7/7] mm: move madvise vma flags to the end
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Sat, 31 Mar 2012 13:29:33 +0400
Message-ID: <20120331092933.19920.29313.stgit@zurg>
In-Reply-To: <20120331091049.19373.28994.stgit@zurg>
References: <20120331091049.19373.28994.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>

Let's collect them together.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/mm.h |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 3a4d721..5e89a4f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -91,10 +91,6 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_LOCKED	0x00002000
 #define VM_IO           0x00004000	/* Memory mapped I/O or similar */
 
-					/* Used by sys_madvise() */
-#define VM_SEQ_READ	0x00008000	/* App will access data sequentially */
-#define VM_RAND_READ	0x00010000	/* App will not benefit from clustered reads */
-
 #define VM_DONTCOPY	0x00020000      /* Do not copy this vma on fork */
 #define VM_DONTEXPAND	0x00040000	/* Cannot expand with mremap() */
 #define VM_RESERVED	0x00080000	/* Count as reserved_vm like IO */
@@ -103,8 +99,11 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_HUGETLB	0x00400000	/* Huge TLB Page VM */
 #define VM_NONLINEAR	0x00800000	/* Is non-linear (remap_file_pages) */
 #define VM_ARCH_1	0x01000000	/* Architecture-specific flag */
-#define VM_NODUMP	0x04000000	/* Do not include in the core dump */
 
+					/* Used by sys_madvise() */
+#define VM_NODUMP	0x04000000	/* Do not include in the core dump */
+#define VM_SEQ_READ	0x08000000	/* App will access data sequentially */
+#define VM_RAND_READ	0x10000000	/* App will not benefit from clustered reads */
 #define VM_HUGEPAGE	0x20000000	/* MADV_HUGEPAGE marked this vma */
 #define VM_NOHUGEPAGE	0x40000000	/* MADV_NOHUGEPAGE marked this vma */
 #define VM_MERGEABLE	0x80000000	/* KSM may merge identical pages */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
