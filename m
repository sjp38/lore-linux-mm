Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E415E6B02FA
	for <linux-mm@kvack.org>; Tue, 16 May 2017 05:23:42 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id w79so28355409wme.7
        for <linux-mm@kvack.org>; Tue, 16 May 2017 02:23:42 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id z35si1259618wrb.20.2017.05.16.02.23.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 May 2017 02:23:41 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4G9Nb6F021095
	for <linux-mm@kvack.org>; Tue, 16 May 2017 05:23:40 -0400
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2aft10v9fc-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 May 2017 05:23:40 -0400
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 16 May 2017 03:23:39 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH v2 0/9] HugeTLB migration support for PPC64
Date: Tue, 16 May 2017 14:53:23 +0530
Message-Id: <1494926612-23928-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mpe@ellerman.id.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

HugeTLB migration support for PPC64

Changes from V1:
* Added Reviewed-by:
* Drop follow_huge_addr from powerpc

Aneesh Kumar K.V (8):
  mm/hugetlb/migration: Use set_huge_pte_at instead of set_pte_at
  mm/follow_page_mask: Split follow_page_mask to smaller functions.
  mm/hugetlb: export hugetlb_entry_migration helper
  mm/hugetlb: Move default definition of hugepd_t earlier in the header
  mm/follow_page_mask: Add support for hugepage directory entry
  powerpc/hugetlb: Add follow_huge_pd implementation for ppc64.
  powerpc/mm/hugetlb: Remove follow_huge_addr for powerpc
  powerpc/hugetlb: Enable hugetlb migration for ppc64

Anshuman Khandual (1):
  mm/follow_page_mask: Add support for hugetlb pgd entries.

 arch/powerpc/mm/hugetlbpage.c          |  81 ++++++--------
 arch/powerpc/platforms/Kconfig.cputype |   5 +
 include/linux/hugetlb.h                |  56 ++++++----
 mm/gup.c                               | 186 +++++++++++++++++++++++----------
 mm/hugetlb.c                           |  25 ++++-
 mm/migrate.c                           |  21 ++--
 6 files changed, 230 insertions(+), 144 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
