Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id A41A06B0038
	for <linux-mm@kvack.org>; Fri,  1 May 2015 01:43:55 -0400 (EDT)
Received: by pabtp1 with SMTP id tp1so81949405pab.2
        for <linux-mm@kvack.org>; Thu, 30 Apr 2015 22:43:55 -0700 (PDT)
Received: from e28smtp08.in.ibm.com (e28smtp08.in.ibm.com. [122.248.162.8])
        by mx.google.com with ESMTPS id x5si6611368pde.28.2015.04.30.22.43.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Apr 2015 22:43:54 -0700 (PDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 1 May 2015 11:13:49 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 7EB9D1258059
	for <linux-mm@kvack.org>; Fri,  1 May 2015 11:15:49 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t415hj5b40566870
	for <linux-mm@kvack.org>; Fri, 1 May 2015 11:13:46 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t415hjnB005929
	for <linux-mm@kvack.org>; Fri, 1 May 2015 11:13:45 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V2 0/2] Remove _PAGE_SPLITTING from ppc64 
Date: Fri,  1 May 2015 11:13:24 +0530
Message-Id: <1430459006-18142-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mpe@ellerman.id.au, paulus@samba.org, benh@kernel.crashing.org, kirill.shutemov@linux.intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

The changes are on top of what is posted  at

 http://mid.gmane.org/1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com

 git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git thp/refcounting/v5

Changes from V1:
* Fold part of patch 3 to 1 and 2
* Drop patch 3.
* Make generic version of pmdp_splitting_flush_notify inline.

Aneesh Kumar K.V (2):
  mm/thp: Use new functions to clear pmd on splitting and collapse
  powerpc/thp: Remove _PAGE_SPLITTING and related code

 arch/powerpc/include/asm/kvm_book3s_64.h |   6 --
 arch/powerpc/include/asm/pgtable-ppc64.h |  29 ++------
 arch/powerpc/mm/hugepage-hash64.c        |   3 -
 arch/powerpc/mm/hugetlbpage.c            |   2 +-
 arch/powerpc/mm/pgtable_64.c             | 111 ++++++++++++-------------------
 include/asm-generic/pgtable.h            |  32 +++++++++
 mm/gup.c                                 |   2 +-
 mm/huge_memory.c                         |   9 +--
 8 files changed, 89 insertions(+), 105 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
