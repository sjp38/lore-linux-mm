Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id AEFAC6B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 08:24:00 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id i187so99981987lfe.4
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 05:24:00 -0700 (PDT)
Received: from mail.zhinst.com (mail.zhinst.com. [212.126.164.98])
        by mx.google.com with ESMTP id u85si18552890lff.297.2016.10.17.05.23.58
        for <linux-mm@kvack.org>;
        Mon, 17 Oct 2016 05:23:59 -0700 (PDT)
From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] mm/gup: Make unnecessarily global vma_permits_fault() static
Date: Mon, 17 Oct 2016 14:23:53 +0200
Message-Id: <20161017122353.31598-1-tklauser@distanz.ch>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-mm@kvack.org

Make vma_permits_fault() static as it is only used in mm/gup.c

This fixes a sparse warning.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 mm/gup.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/gup.c b/mm/gup.c
index 96b2b2fd0fbd..a52766e1afe8 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -623,7 +623,8 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 }
 EXPORT_SYMBOL(__get_user_pages);
 
-bool vma_permits_fault(struct vm_area_struct *vma, unsigned int fault_flags)
+static bool vma_permits_fault(struct vm_area_struct *vma,
+			      unsigned int fault_flags)
 {
 	bool write   = !!(fault_flags & FAULT_FLAG_WRITE);
 	bool foreign = !!(fault_flags & FAULT_FLAG_REMOTE);
-- 
2.9.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
