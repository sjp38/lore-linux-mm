Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id C71706B007E
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 08:48:26 -0400 (EDT)
Received: by mail-pf0-f180.google.com with SMTP id u190so26480669pfb.3
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 05:48:26 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id ly8si4232329pab.89.2016.03.23.05.48.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Mar 2016 05:48:26 -0700 (PDT)
From: Vaishali Thakkar <vaishali.thakkar@oracle.com>
Subject: [PATCH v2 0/6] mm/hugetlb: Fix commandline parsing behavior for invalid hugepagesize
Date: Wed, 23 Mar 2016 17:37:18 +0530
Message-Id: <1458734844-14833-1-git-send-email-vaishali.thakkar@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, n-horiguchi@ah.jp.nec.com, mike.kravetz@oracle.com, hillf.zj@alibaba-inc.com, mhocko@suse.com, baiyaowei@cmss.chinamobile.com, dingel@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com, paul.gortmaker@windriver.com, catalin.marinas@arm.com, will.deacon@arm.com, cmetcalf@ezchip.com, linux-arm-kernel@lists.infradead.org, james.hogan@imgtec.com, linux-metag@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, Vaishali Thakkar <vaishali.thakkar@oracle.com>

Current code fails to ignore the 'hugepages=' parameters when unsupported
hugepagesize is specified. With this patchset, introduce new architecture
independent routine hugetlb_bad_size to handle such command line options.
And then call it in architecture specific code.

Changes since v1:
	- Separated different architecture specific changes in different
	  patches
	- CC'ed all arch maintainers

Vaishali Thakkar (6):
  mm/hugetlb: Introduce hugetlb_bad_size
  arm64: mm: Use hugetlb_bad_size
  metag: mm: Use hugetlb_bad_size
  powerpc: mm: Use hugetlb_bad_size
  tile: mm: Use hugetlb_bad_size
  x86: mm: Use hugetlb_bad_size

 arch/arm64/mm/hugetlbpage.c   |  1 +
 arch/metag/mm/hugetlbpage.c   |  1 +
 arch/powerpc/mm/hugetlbpage.c |  6 ++++--
 arch/tile/mm/hugetlbpage.c    |  7 ++++++-
 arch/x86/mm/hugetlbpage.c     |  1 +
 include/linux/hugetlb.h       |  1 +
 mm/hugetlb.c                  | 14 +++++++++++++-
 7 files changed, 27 insertions(+), 4 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
