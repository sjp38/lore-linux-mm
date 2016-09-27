Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C81B0280290
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 12:08:40 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b130so12652527wmc.2
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 09:08:40 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y6si3055349wjg.51.2016.09.27.09.08.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Sep 2016 09:08:35 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 11/20] mm: Remove unnecessary vma->vm_ops check
Date: Tue, 27 Sep 2016 18:08:15 +0200
Message-Id: <1474992504-20133-12-git-send-email-jack@suse.cz>
In-Reply-To: <1474992504-20133-1-git-send-email-jack@suse.cz>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>

We don't check whether vma->vm_ops is NULL in do_shared_fault() so
there's hardly any point in checking it in wp_page_shared() which gets
called only for shared file mappings as well.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/memory.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index a4522e8999b2..63d9c1a54caf 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2301,7 +2301,7 @@ static int wp_page_shared(struct vm_fault *vmf, struct page *old_page)
 
 	get_page(old_page);
 
-	if (vma->vm_ops && vma->vm_ops->page_mkwrite) {
+	if (vma->vm_ops->page_mkwrite) {
 		int tmp;
 
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
