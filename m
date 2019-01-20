Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id E56198E0002
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 03:14:20 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id p12so9090506wrt.17
        for <linux-mm@kvack.org>; Sun, 20 Jan 2019 00:14:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j19sor61875696wre.41.2019.01.20.00.14.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 20 Jan 2019 00:14:19 -0800 (PST)
From: Yang Fan <nullptr.cpp@gmail.com>
Subject: [PATCH 2/2] mm/mmap.c: Remove redundant const qualifier of the no-pointer parameters
Date: Sun, 20 Jan 2019 09:13:45 +0100
Message-Id: <a1ef2a2113cd8847002f0064f198aa4afe465548.1547966629.git.nullptr.cpp@gmail.com>
In-Reply-To: <cover.1547966629.git.nullptr.cpp@gmail.com>
References: <cover.1547966629.git.nullptr.cpp@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, will.deacon@arm.com
Cc: Yang Fan <nullptr.cpp@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

In according with other functions, remove the const qualifier of the 
no-pointer parameters in function arch_get_unmapped_area_topdown().

Signed-off-by: Yang Fan <nullptr.cpp@gmail.com>
---
 mm/mmap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index f2d163ac827a..84cdde125d4d 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2127,8 +2127,8 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 #ifndef HAVE_ARCH_UNMAPPED_AREA_TOPDOWN
 unsigned long
 arch_get_unmapped_area_topdown(struct file *filp, unsigned long addr,
-			  const unsigned long len, const unsigned long pgoff,
-			  const unsigned long flags)
+			  unsigned long len, unsigned long pgoff,
+			  unsigned long flags)
 {
 	struct vm_area_struct *vma, *prev;
 	struct mm_struct *mm = current->mm;
-- 
2.17.1
