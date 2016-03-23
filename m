Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id 2732F6B025E
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 08:49:29 -0400 (EDT)
Received: by mail-oi0-f52.google.com with SMTP id d205so17876461oia.0
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 05:49:29 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id y5si1226547obg.55.2016.03.23.05.49.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Mar 2016 05:49:28 -0700 (PDT)
From: Vaishali Thakkar <vaishali.thakkar@oracle.com>
Subject: [PATCH v2 3/6] metag: mm: Use hugetlb_bad_size
Date: Wed, 23 Mar 2016 18:00:46 +0530
Message-Id: <1458736246-15830-1-git-send-email-vaishali.thakkar@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: james.hogan@imgtec.com, linux-metag@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vaishali Thakkar <vaishali.thakkar@oracle.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Michal Hocko <mhocko@suse.com>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Dave Hansen <dave.hansen@linux.intel.com>

Update the setup_hugepagesz function to call the routine
hugetlb_bad_size when unsupported hugepage size is found.

Signed-off-by: Vaishali Thakkar <vaishali.thakkar@oracle.com>
Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Cc: Dominik Dingel <dingel@linux.vnet.ibm.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
---
Please note that the patch is tested for x86 only. But as this
is one line change I just changed them all. So, it would be good
if the patch can be tested for other architectures before adding
this in to mainline.
Changes since v1:
	- Separate different arch specific changes in different
          patches instead of one
---
 arch/metag/mm/hugetlbpage.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/metag/mm/hugetlbpage.c b/arch/metag/mm/hugetlbpage.c
index b38700a..db1b7da 100644
--- a/arch/metag/mm/hugetlbpage.c
+++ b/arch/metag/mm/hugetlbpage.c
@@ -239,6 +239,7 @@ static __init int setup_hugepagesz(char *opt)
 	if (ps == (1 << HPAGE_SHIFT)) {
 		hugetlb_add_hstate(HPAGE_SHIFT - PAGE_SHIFT);
 	} else {
+		hugetlb_bad_size();
 		pr_err("hugepagesz: Unsupported page size %lu M\n",
 		       ps >> 20);
 		return 0;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
