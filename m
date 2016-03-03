Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 4CAEF6B025F
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 05:03:16 -0500 (EST)
Received: by mail-qg0-f43.google.com with SMTP id w104so12905015qge.1
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 02:03:16 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d90si8368707qge.118.2016.03.03.02.03.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Mar 2016 02:03:15 -0800 (PST)
From: Jan Stancek <jstancek@redhat.com>
Subject: [PATCH] mm/hugetlb: use EOPNOTSUPP in hugetlb sysctl handlers
Date: Thu,  3 Mar 2016 11:02:51 +0100
Message-Id: <bdc32a3ce19bd1fa232852d179a6af958778c2c0.1456999026.git.jstancek@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, mike.kravetz@oracle.com, hillf.zj@alibaba-inc.com, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com, paul.gortmaker@windriver.com, jstancek@redhat.com

Replace ENOTSUPP with EOPNOTSUPP. If hugepages are not supported,
this value is propagated to userspace. EOPNOTSUPP is part of uapi
and is widely supported by libc libraries.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>

Signed-off-by: Jan Stancek <jstancek@redhat.com>
---
 mm/hugetlb.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 01f2b48c8618..851a29928a99 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2751,7 +2751,7 @@ static int hugetlb_sysctl_handler_common(bool obey_mempolicy,
 	int ret;
 
 	if (!hugepages_supported())
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 
 	table->data = &tmp;
 	table->maxlen = sizeof(unsigned long);
@@ -2792,7 +2792,7 @@ int hugetlb_overcommit_handler(struct ctl_table *table, int write,
 	int ret;
 
 	if (!hugepages_supported())
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 
 	tmp = h->nr_overcommit_huge_pages;
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
