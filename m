Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id E1ABE8E0002
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 03:13:32 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id y1so9085905wrd.7
        for <linux-mm@kvack.org>; Sun, 20 Jan 2019 00:13:32 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n12sor11161779wrv.1.2019.01.20.00.13.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 20 Jan 2019 00:13:31 -0800 (PST)
From: Yang Fan <nullptr.cpp@gmail.com>
Subject: [PATCH 1/2] mm/mmap.c: Remove redundant variable 'addr' in arch_get_unmapped_area_topdown()
Date: Sun, 20 Jan 2019 09:13:24 +0100
Message-Id: <affba895224614ac3f2cbafa9d4fa7be3361de9d.1547966629.git.nullptr.cpp@gmail.com>
In-Reply-To: <cover.1547966629.git.nullptr.cpp@gmail.com>
References: <cover.1547966629.git.nullptr.cpp@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, will.deacon@arm.com
Cc: Yang Fan <nullptr.cpp@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The variable 'addr' is redundant in arch_get_unmapped_area_topdown(), 
just use parameter 'addr0' directly. Then remove the const qualifier 
of the parameter, and change its name to 'addr'.

Signed-off-by: Yang Fan <nullptr.cpp@gmail.com>
---
 mm/mmap.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index f901065c4c64..f2d163ac827a 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2126,13 +2126,12 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
  */
 #ifndef HAVE_ARCH_UNMAPPED_AREA_TOPDOWN
 unsigned long
-arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
+arch_get_unmapped_area_topdown(struct file *filp, unsigned long addr,
 			  const unsigned long len, const unsigned long pgoff,
 			  const unsigned long flags)
 {
 	struct vm_area_struct *vma, *prev;
 	struct mm_struct *mm = current->mm;
-	unsigned long addr = addr0;
 	struct vm_unmapped_area_info info;
 	const unsigned long mmap_end = arch_get_mmap_end(addr);
 
-- 
2.17.1
