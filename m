Date: Fri, 2 May 2008 05:20:33 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 1/4] mm: allow pfnmap ->fault()s
Message-ID: <20080502032032.GE11844@wotan.suse.de>
References: <20080502031903.GD11844@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080502031903.GD11844@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, jk@ozlabs.org, jes@trained-monkey.org, cpw@sgi.com
List-ID: <linux-mm.kvack.org>

Take out an assertion to allow ->fault handlers to service PFNMAP regions.
This is required to reimplement .nopfn handlers with .fault handlers and
subsequently remove nopfn.

Signed-off-by: Nick Piggin <npiggin@suse.de>
Acked-by: Jes Sorensen <jes@sgi.com>
---

 mm/memory.c |    2 --
 1 file changed, 2 deletions(-)

Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -2275,8 +2275,6 @@ static int __do_fault(struct mm_struct *
 	vmf.flags = flags;
 	vmf.page = NULL;
 
-	BUG_ON(vma->vm_flags & VM_PFNMAP);
-
 	ret = vma->vm_ops->fault(vma, &vmf);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
 		return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
