Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id F36556B000E
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 00:45:26 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id wq6so93758301pac.1
        for <linux-mm@kvack.org>; Sun, 20 Dec 2015 21:45:26 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id g8si8648029pfg.120.2015.12.20.21.45.16
        for <linux-mm@kvack.org>;
        Sun, 20 Dec 2015 21:45:16 -0800 (PST)
Subject: [-mm PATCH v4 08/18] hugetlb: fix compile error on tile
From: Dan Williams <dan.j.williams@intel.com>
Date: Sun, 20 Dec 2015 21:44:49 -0800
Message-ID: <20151221054449.34542.85256.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151221054406.34542.64393.stgit@dwillia2-desk3.jf.intel.com>
References: <20151221054406.34542.64393.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-nvdimm@lists.01.org

Inlude asm/pgtable.h to get the definition for pud_t to fix:

include/linux/hugetlb.h:203:29: error: unknown type name 'pud_t'

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/hugetlb.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 204c7f56f35a..2b61bf566161 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -8,6 +8,7 @@
 #include <linux/cgroup.h>
 #include <linux/list.h>
 #include <linux/kref.h>
+#include <asm/pgtable.h>
 
 struct ctl_table;
 struct user_struct;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
