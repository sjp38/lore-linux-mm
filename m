Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6224A6B4730
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 13:48:56 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id a26-v6so1547581pgw.7
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 10:48:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t8-v6sor512451plq.113.2018.08.28.10.48.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Aug 2018 10:48:55 -0700 (PDT)
Date: Tue, 28 Aug 2018 23:21:54 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH] mm: Conveted to use vm_fault_t
Message-ID: <20180828174952.GA29229@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, jack@suse.cz, mgorman@techsingularity.net, ak@linux.intel.com, mawilcox@microsoft.com, tim.c.chen@linux.intel.com, ross.zwisler@linux.intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

As part of vm_fault_t conversion filemap_page_mkwrite()
for NOMMU case was missed. Now converted.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
---
 mm/filemap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 52517f2..de6fed2 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2748,9 +2748,9 @@ int generic_file_readonly_mmap(struct file *file, struct vm_area_struct *vma)
 	return generic_file_mmap(file, vma);
 }
 #else
-int filemap_page_mkwrite(struct vm_fault *vmf)
+vm_fault_t filemap_page_mkwrite(struct vm_fault *vmf)
 {
-	return -ENOSYS;
+	return VM_FAULT_SIGBUS;
 }
 int generic_file_mmap(struct file * file, struct vm_area_struct * vma)
 {
-- 
1.9.1
