Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0DDB26B0284
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 20:34:24 -0500 (EST)
Received: by pacej9 with SMTP id ej9so3069735pac.2
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 17:34:23 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id g79si1275163pfj.185.2015.12.07.17.34.23
        for <linux-mm@kvack.org>;
        Mon, 07 Dec 2015 17:34:23 -0800 (PST)
Subject: [PATCH -mm 14/25] hugetlb: fix compile error on tile
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 07 Dec 2015 17:33:50 -0800
Message-ID: <20151208013350.25030.66853.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151208013236.25030.68781.stgit@dwillia2-desk3.jf.intel.com>
References: <20151208013236.25030.68781.stgit@dwillia2-desk3.jf.intel.com>
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
