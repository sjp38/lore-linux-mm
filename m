Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9C1A96B0038
	for <linux-mm@kvack.org>; Mon,  1 May 2017 02:34:52 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h87so68516508pfh.2
        for <linux-mm@kvack.org>; Sun, 30 Apr 2017 23:34:52 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id 89si13936402pft.220.2017.04.30.23.34.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Apr 2017 23:34:51 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id v14so26689778pfd.3
        for <linux-mm@kvack.org>; Sun, 30 Apr 2017 23:34:51 -0700 (PDT)
From: Balbir Singh <bsingharora@gmail.com>
Subject: [PATCH v2 0/3] Implement page table accounting for powerpc
Date: Mon,  1 May 2017 16:34:35 +1000
Message-Id: <20170501063438.25237-1-bsingharora@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vdavydov@virtuozzo.com, mpe@ellerman.id.au, oss@buserror.net
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>

(3e79ec7 arch: x86: charge page tables to kmemcg) added support for page
table accounting). This patch is the second iteration to add
support, in the earlier iteration only book3s 64 bit was supported.
This iteration adds support for booke/3s/32 and 64 bit.

There is some ugliness in this patchset, pgalloc.h is included
from book3s_64_mmu_radix.c to reuse the pte/pmd/pud and pgd
management routines. We use #ifdef MODULE to provide a version
that provides full accounting. The alternatives are discussed
in patch 1 below

Changelog v2:
 - Added support for 32 bit and booke
 - Added hugepte alloc accounting


Balbir Singh (3):
  powerpc/mm/book(e)(3s)/64: Add page table accounting
  powerpc/mm/book(e)(3s)/32: Add page table accounting
  powerpc/mm/hugetlb: Add support for page accounting

 arch/powerpc/include/asm/book3s/32/pgalloc.h |  3 ++-
 arch/powerpc/include/asm/book3s/64/pgalloc.h | 17 +++++++++++------
 arch/powerpc/include/asm/nohash/32/pgalloc.h |  3 ++-
 arch/powerpc/include/asm/nohash/64/pgalloc.h | 12 ++++++++----
 arch/powerpc/include/asm/pgalloc.h           | 14 ++++++++++++++
 arch/powerpc/mm/hugetlbpage.c                |  2 +-
 arch/powerpc/mm/pgtable_32.c                 |  2 +-
 arch/powerpc/mm/pgtable_64.c                 |  3 ++-
 8 files changed, 41 insertions(+), 15 deletions(-)

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
