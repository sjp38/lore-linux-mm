Date: Fri, 14 Nov 2008 19:49:42 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH mmotm] mm: don't mark_page_accessed in shmem_fault
Message-ID: <Pine.LNX.4.64.0811141944540.12769@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@saeurebad.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Following "mm: don't mark_page_accessed in fault path", which now
places a mark_page_accessed() in zap_pte_range(), we should remove
the mark_page_accessed() from shmem_fault().

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---
You guessed it, follows mm-dont-mark_page_accessed-in-fault-path.patch

 mm/shmem.c |    1 -
 1 file changed, 1 deletion(-)

--- 2.6.28-rc4/mm/shmem.c	2008-11-02 23:17:56.000000000 +0000
+++ linux/mm/shmem.c	2008-11-14 19:06:54.000000000 +0000
@@ -1444,7 +1444,6 @@ static int shmem_fault(struct vm_area_st
 	if (error)
 		return ((error == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS);
 
-	mark_page_accessed(vmf->page);
 	return ret | VM_FAULT_LOCKED;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
