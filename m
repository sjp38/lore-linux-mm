Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6DAE86B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 12:20:39 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id z2-v6so5204457plk.3
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 09:20:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u10sor984873pgv.360.2018.04.05.09.20.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Apr 2018 09:20:38 -0700 (PDT)
Date: Thu, 5 Apr 2018 21:52:25 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH] include: mm: Adding new inline function vmf_error
Message-ID: <20180405162225.GA23411@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org

Many places in drivers/ file systems error was handled
like below -
ret = (ret == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS;

This new inline function vmf_error() will replace this
and return vm_fault_t type err.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
---
 include/linux/mm.h | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index a4d8853..e283dd8 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2453,6 +2453,18 @@ static inline vm_fault_t vmf_insert_pfn(struct vm_area_struct *vma,
 	return VM_FAULT_NOPAGE;
 }
 
+static inline vm_fault_t vmf_error(int err)
+{
+	vm_fault_t ret;
+
+	if (err == -ENOMEM)
+		ret = VM_FAULT_OOM;
+	else
+		ret = VM_FAULT_SIGBUS;
+
+	return ret;
+}
+
 struct page *follow_page_mask(struct vm_area_struct *vma,
 			      unsigned long address, unsigned int foll_flags,
 			      unsigned int *page_mask);
-- 
1.9.1
