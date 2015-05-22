Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 753BE6B00EB
	for <linux-mm@kvack.org>; Fri, 22 May 2015 01:18:50 -0400 (EDT)
Received: by pdea3 with SMTP id a3so10329844pde.2
        for <linux-mm@kvack.org>; Thu, 21 May 2015 22:18:50 -0700 (PDT)
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com. [202.81.31.148])
        by mx.google.com with ESMTPS id w2si1693260pde.152.2015.05.21.22.18.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Thu, 21 May 2015 22:18:49 -0700 (PDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 22 May 2015 15:18:44 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id E68923578055
	for <linux-mm@kvack.org>; Fri, 22 May 2015 15:18:38 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t4M5ITdf8978436
	for <linux-mm@kvack.org>; Fri, 22 May 2015 15:18:38 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t4M5I4ms023216
	for <linux-mm@kvack.org>; Fri, 22 May 2015 15:18:05 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V6 0/3] THP related code cleanup
Date: Fri, 22 May 2015 10:47:29 +0530
Message-Id: <1432271852-12949-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, kirill.shutemov@linux.intel.com, aarcange@redhat.com, schwidefsky@de.ibm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Changes from v5:
* Fix build failure on x86 with thp enabled.
* Tested on x86_64, ppc64.

Aneesh Kumar K.V (3):
  mm/thp: Split out pmd collpase flush into a separate functions
  powerpc/mm: Use generic version of pmdp_clear_flush
  mm: Clarify that the function operates on hugepage pte

 arch/mips/include/asm/pgtable.h          |  8 ++--
 arch/powerpc/include/asm/pgtable-ppc64.h | 14 +++---
 arch/powerpc/mm/pgtable_64.c             | 73 +++++++++++++++-----------------
 arch/s390/include/asm/pgtable.h          | 30 ++++++++-----
 arch/sparc/include/asm/pgtable_64.h      |  8 ++--
 arch/tile/include/asm/pgtable.h          |  8 ++--
 arch/x86/include/asm/pgtable.h           |  4 +-
 include/asm-generic/pgtable.h            | 34 +++++++++++----
 include/linux/mmu_notifier.h             | 12 +++---
 mm/huge_memory.c                         | 18 ++++----
 mm/migrate.c                             |  2 +-
 mm/pgtable-generic.c                     | 29 +++++++++++--
 mm/rmap.c                                |  2 +-
 13 files changed, 141 insertions(+), 101 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
