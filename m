Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 243AB6B007E
	for <linux-mm@kvack.org>; Mon,  7 Sep 2009 22:38:16 -0400 (EDT)
Received: by pzk17 with SMTP id 17so3004039pzk.16
        for <linux-mm@kvack.org>; Mon, 07 Sep 2009 19:38:17 -0700 (PDT)
From: Huang Shijie <shijie8@gmail.com>
Subject: [PATCH] mmap : remove unnecessary code
Date: Tue,  8 Sep 2009 10:38:14 +0800
Message-Id: <1252377494-9187-1-git-send-email-shijie8@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Huang Shijie <shijie8@gmail.com>
List-ID: <linux-mm.kvack.org>

If (flags & MAP_LOCKED) is true, it means vm_flags has already contained
the bit VM_LOCKED which is set by calc_vm_flag_bits().

So there is no need to reset it again, just remove it.

Signed-off-by: Huang Shijie <shijie8@gmail.com>
---
 mm/mmap.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 8101de4..6b240ce 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -965,11 +965,9 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 	vm_flags = calc_vm_prot_bits(prot) | calc_vm_flag_bits(flags) |
 			mm->def_flags | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
 
-	if (flags & MAP_LOCKED) {
+	if (flags & MAP_LOCKED)
 		if (!can_do_mlock())
 			return -EPERM;
-		vm_flags |= VM_LOCKED;
-	}
 
 	/* mlock MCL_FUTURE? */
 	if (vm_flags & VM_LOCKED) {
-- 
1.6.0.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
