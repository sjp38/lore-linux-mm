Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6AE566B0169
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 10:59:21 -0400 (EDT)
Date: Tue, 23 Aug 2011 09:59:18 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC] mm: Distinguish between mlocked and pinned pages
In-Reply-To: <20110817155412.cc302033.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1108230958510.21267@router.home>
References: <alpine.DEB.2.00.1108101516430.20403@router.home> <20110817155412.cc302033.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-rdma@vger.kernel.org, Hugh Dickins <hughd@google.com>

On Wed, 17 Aug 2011, Andrew Morton wrote:

> This is an obvious place.  Could I ask that you split all these up into
> one-definition-per-line and we can start in on properly documenting
> each field?

Subject: mm: Add comments to explain mm_struct fields

Explain comments to explain the page statistics field in the
mm_struct.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 include/linux/mm_types.h |   11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

Index: linux-2.6/include/linux/mm_types.h
===================================================================
--- linux-2.6.orig/include/linux/mm_types.h	2011-08-23 09:43:32.000000000 -0500
+++ linux-2.6/include/linux/mm_types.h	2011-08-23 09:52:09.000000000 -0500
@@ -281,8 +281,15 @@ struct mm_struct {
 	unsigned long hiwater_rss;	/* High-watermark of RSS usage */
 	unsigned long hiwater_vm;	/* High-water virtual memory usage */

-	unsigned long total_vm, locked_vm, pinned_vm, shared_vm, exec_vm;
-	unsigned long stack_vm, reserved_vm, def_flags, nr_ptes;
+	unsigned long total_vm;		/* Total pages mapped */
+	unsigned long locked_vm		/* Pages that have PG_mlocked set */
+	unsigned long pinned_vm;	/* Refcount permanently increased */
+	unsigned long shared_vm;	/* Shared pages (files) */
+	unsigned long exec_vm;		/* VM_EXEC & ~VM_WRITE */
+	unsigned long stack_vm;		/* VM_GROWSUP/DOWN */
+	unsigned long reserved_vm;	/* VM_RESERVED|VM_IO pages */
+	unsigned long def_flags;
+	unsigned long nr_ptes;		/* Page table pages */
 	unsigned long start_code, end_code, start_data, end_data;
 	unsigned long start_brk, brk, start_stack;
 	unsigned long arg_start, arg_end, env_start, env_end;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
