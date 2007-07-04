Date: Wed, 4 Jul 2007 03:52:25 -0400 (EDT)
From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: [PATCH] MM: Make needlessly global hugetlb_no_page() static.
Message-ID: <Pine.LNX.4.64.0707040352040.2922@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@osdl.org>, Adrian Bunk <bunk@stusta.de>
List-ID: <linux-mm.kvack.org>

Signed-off-by: Robert P. J. Day <rpjday@mindspring.com>

---

  i'm assuming that, given the following:

$ grep -rw hugetlb_no_page *
mm/hugetlb.c:int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
mm/hugetlb.c:           ret = hugetlb_no_page(mm, vma, address, ptep, write_access);

if a routine is both declared and defined in a single translation
unit, and isn't EXPORT_SYMBOLed in some way, that's pretty much the
definition of needlessly global, right?


diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index a45d1f0..6d7abaf 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -474,7 +474,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 	return VM_FAULT_MINOR;
 }

-int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
+static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, pte_t *ptep, int write_access)
 {
 	int ret = VM_FAULT_SIGBUS;
-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://fsdev.net/wiki/index.php?title=Main_Page
========================================================================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
