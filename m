Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 418D76B03A3
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 13:12:08 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 72so91781217pge.10
        for <linux-mm@kvack.org>; Mon, 17 Apr 2017 10:12:08 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id i62si8645487pge.48.2017.04.17.10.12.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Apr 2017 10:12:07 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3HH92ip120941
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 13:12:06 -0400
Received: from e11.ny.us.ibm.com (e11.ny.us.ibm.com [129.33.205.201])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29w0p637jh-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 13:12:06 -0400
Received: from localhost
	by e11.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 17 Apr 2017 13:12:05 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH 0/7] HugeTLB migration support for PPC64
Date: Mon, 17 Apr 2017 22:41:39 +0530
Message-Id: <1492449106-27467-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mpe@ellerman.id.au, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This patch series add support for hugetlb page migration.

Aneesh Kumar K.V (6):
  mm/hugetlb/migration: Use set_huge_pte_at instead of set_pte_at
  mm/follow_page_mask: Split follow_page_mask to smaller functions.
  mm/hugetlb: export hugetlb_entry_migration helper
  mm/follow_page_mask: Add support for hugepage directory entry
  powerpc/hugetlb: Add follow_huge_pd implementation for ppc64.
  powerpc/hugetlb: Enable hugetlb migration for ppc64

Anshuman Khandual (1):
  mm/follow_page_mask: Add support for hugetlb pgd entries.

 arch/powerpc/mm/hugetlbpage.c          |  43 ++++++++
 arch/powerpc/platforms/Kconfig.cputype |   5 +
 include/linux/hugetlb.h                |   9 ++
 mm/gup.c                               | 186 +++++++++++++++++++++++----------
 mm/hugetlb.c                           |  25 ++++-
 mm/migrate.c                           |  21 ++--
 6 files changed, 219 insertions(+), 70 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
