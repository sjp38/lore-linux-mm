Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 3CB906B006E
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 04:25:59 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so53097186pac.1
        for <linux-mm@kvack.org>; Thu, 30 Apr 2015 01:25:59 -0700 (PDT)
Received: from e28smtp08.in.ibm.com (e28smtp08.in.ibm.com. [122.248.162.8])
        by mx.google.com with ESMTPS id q2si2425099pde.187.2015.04.30.01.25.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Apr 2015 01:25:58 -0700 (PDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 30 Apr 2015 13:55:54 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 31F41E005F
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 13:58:38 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3U8PptI40173682
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 13:55:51 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3U8PoBX029884
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 13:55:50 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH 0/3] Remove _PAGE_SPLITTING from ppc64
Date: Thu, 30 Apr 2015 13:55:38 +0530
Message-Id: <1430382341-8316-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, paulus@samba.org, benh@kernel.crashing.org, kirill.shutemov@linux.intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

The changes are on top of what is posted  at

http://mid.gmane.org/1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com

git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git thp/refcounting/v5

Aneesh Kumar K.V (3):
  mm/thp: Use pmdp_splitting_flush_notify to clear pmd on splitting
  powerpc/thp: Remove _PAGE_SPLITTING and related code
  mm/thp: Add new function to clear pmd on collapse

 arch/powerpc/include/asm/kvm_book3s_64.h |   6 --
 arch/powerpc/include/asm/pgtable-ppc64.h |  29 ++------
 arch/powerpc/mm/hugepage-hash64.c        |   3 -
 arch/powerpc/mm/hugetlbpage.c            |   2 +-
 arch/powerpc/mm/pgtable_64.c             | 111 ++++++++++++-------------------
 include/asm-generic/pgtable.h            |  14 ++++
 mm/gup.c                                 |   2 +-
 mm/huge_memory.c                         |   9 +--
 mm/pgtable-generic.c                     |  11 +++
 9 files changed, 82 insertions(+), 105 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
