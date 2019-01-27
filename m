Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 295148E00C8
	for <linux-mm@kvack.org>; Sat, 26 Jan 2019 23:12:15 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id z16so5293705wrt.5
        for <linux-mm@kvack.org>; Sat, 26 Jan 2019 20:12:15 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z16sor40862404wmc.11.2019.01.26.20.12.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 26 Jan 2019 20:12:13 -0800 (PST)
From: Yang Fan <nullptr.cpp@gmail.com>
Subject: [PATCH v2] mm/mmap.c: Remove some redundancy in arch_get_unmapped_area_topdown()
Date: Sun, 27 Jan 2019 05:11:12 +0100
Message-Id: <20190127041112.25599-1-nullptr.cpp@gmail.com>
References: <cover.1547966629.git.nullptr.cpp@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rppt@linux.ibm.com, william.kucharski@oracle.com, akpm@linux-foundation.org, will.deacon@arm.com
Cc: Yang Fan <nullptr.cpp@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The variable 'addr' is redundant in arch_get_unmapped_area_topdown(), 
just use parameter 'addr0' directly. Then remove the const qualifier 
of the parameter, and change its name to 'addr'.

And in according with other functions, remove the const qualifier of all 
other no-pointer parameters in function arch_get_unmapped_area_topdown().

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>
Signed-off-by: Yang Fan <nullptr.cpp@gmail.com>
---
Changes in v2:
  - Merge the two patches into one.

 mm/mmap.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index f901065c4c64..84cdde125d4d 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2126,13 +2126,12 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
  */
 #ifndef HAVE_ARCH_UNMAPPED_AREA_TOPDOWN
 unsigned long
-arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
-			  const unsigned long len, const unsigned long pgoff,
-			  const unsigned long flags)
+arch_get_unmapped_area_topdown(struct file *filp, unsigned long addr,
+			  unsigned long len, unsigned long pgoff,
+			  unsigned long flags)
 {
 	struct vm_area_struct *vma, *prev;
 	struct mm_struct *mm = current->mm;
-	unsigned long addr = addr0;
 	struct vm_unmapped_area_info info;
 	const unsigned long mmap_end = arch_get_mmap_end(addr);
 
-- 
2.17.1
