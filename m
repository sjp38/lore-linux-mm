Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 0C3276B007E
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 08:50:33 -0400 (EDT)
Received: by mail-io0-f175.google.com with SMTP id v187so9251086ioe.2
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 05:50:33 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id gb2si3924977igd.4.2016.03.23.05.50.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Mar 2016 05:50:04 -0700 (PDT)
From: Vaishali Thakkar <vaishali.thakkar@oracle.com>
Subject: [PATCH v2 6/6] x86: mm: Use hugetlb_bad_size
Date: Wed, 23 Mar 2016 18:09:36 +0530
Message-Id: <1458736776-16201-1-git-send-email-vaishali.thakkar@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vaishali Thakkar <vaishali.thakkar@oracle.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Michal Hocko <mhocko@suse.com>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Dave Hansen <dave.hansen@linux.intel.com>

Update the setup_hugepagesz function to call the routine
hugetlb_bad_size when unsupported hugepage size is found.

Signed-off-by: Vaishali Thakkar <vaishali.thakkar@oracle.com>
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Cc: Dominik Dingel <dingel@linux.vnet.ibm.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
---
Changes since v1:
        - Separate different arch specific changes in different
          patches instead of one
---
 arch/x86/mm/hugetlbpage.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index 740d7ac..3ec44f8 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -165,6 +165,7 @@ static __init int setup_hugepagesz(char *opt)
 	} else if (ps == PUD_SIZE && cpu_has_gbpages) {
 		hugetlb_add_hstate(PUD_SHIFT - PAGE_SHIFT);
 	} else {
+		hugetlb_bad_size();
 		printk(KERN_ERR "hugepagesz: Unsupported page size %lu M\n",
 			ps >> 20);
 		return 0;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
