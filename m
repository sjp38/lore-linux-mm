Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9C65E828E1
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 08:20:05 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id p129so33279674wmp.3
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 05:20:05 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fq8si621426wjc.159.2016.07.22.05.19.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jul 2016 05:19:51 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 09/15] mm: Remove unnecessary vma->vm_ops check
Date: Fri, 22 Jul 2016 14:19:35 +0200
Message-Id: <1469189981-19000-10-git-send-email-jack@suse.cz>
In-Reply-To: <1469189981-19000-1-git-send-email-jack@suse.cz>
References: <1469189981-19000-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>

We don't check whether vma->vm_ops is NULL in do_shared_fault() so
there's hardly any point in checking it in wp_page_shared() which gets
called only for shared file mappings as well.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/memory.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index 6780e5d8145c..61902a5b75c2 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2304,7 +2304,7 @@ static int wp_page_shared(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	get_page(old_page);
 
-	if (vma->vm_ops && vma->vm_ops->page_mkwrite) {
+	if (vma->vm_ops->page_mkwrite) {
 		int tmp;
 
 		pte_unmap_unlock(page_table, ptl);
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
