Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id AF5CF6B007E
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 06:11:01 -0400 (EDT)
Received: by mail-pf0-f175.google.com with SMTP id x3so303688451pfb.1
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 03:11:01 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id f3si13349434pas.21.2016.03.22.03.11.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Mar 2016 03:11:00 -0700 (PDT)
From: Vaishali Thakkar <vaishali.thakkar@oracle.com>
Subject: [PATCH 0/2] mm/hugetlb: Fix commandline parsing behavior for invalid hugepagesize
Date: Tue, 22 Mar 2016 15:40:07 +0530
Message-Id: <1458641409-13689-1-git-send-email-vaishali.thakkar@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, n-horiguchi@ah.jp.nec.com, mike.kravetz@oracle.com, hillf.zj@alibaba-inc.com, mhocko@suse.com, baiyaowei@cmss.chinamobile.com, dingel@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com, paul.gortmaker@windriver.com, Vaishali Thakkar <vaishali.thakkar@oracle.com>

Current code fails to ignore the 'hugepages=' parameters when unsupported
hugepagesize is specified. With this patchset, introduce new architecture
independent routine hugetlb_bad_size to handle such command line options. And
then call it in architecture specific code.

Vaishali Thakkar (2):
  mm/hugetlb: Introduce hugetlb_bad_size
  arch:mm: Use hugetlb_bad_size

 arch/arm64/mm/hugetlbpage.c   |  1 +
 arch/metag/mm/hugetlbpage.c   |  1 +
 arch/powerpc/mm/hugetlbpage.c |  7 +++++--
 arch/tile/mm/hugetlbpage.c    |  7 ++++++-
 arch/x86/mm/hugetlbpage.c     |  1 +
 include/linux/hugetlb.h       |  1 +
 mm/hugetlb.c                  | 14 +++++++++++++-
 7 files changed, 28 insertions(+), 4 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
