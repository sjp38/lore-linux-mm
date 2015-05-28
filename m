Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id A8C256B0071
	for <linux-mm@kvack.org>; Thu, 28 May 2015 07:53:10 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so143573958wic.0
        for <linux-mm@kvack.org>; Thu, 28 May 2015 04:53:10 -0700 (PDT)
Received: from e06smtp17.uk.ibm.com (e06smtp17.uk.ibm.com. [195.75.94.113])
        by mx.google.com with ESMTPS id fr3si4208276wic.113.2015.05.28.04.53.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Thu, 28 May 2015 04:53:00 -0700 (PDT)
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Thu, 28 May 2015 12:52:59 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id CD5501B0805F
	for <linux-mm@kvack.org>; Thu, 28 May 2015 12:53:48 +0100 (BST)
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t4SBqudI22282284
	for <linux-mm@kvack.org>; Thu, 28 May 2015 11:52:56 GMT
Received: from d06av01.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t4SBqmY3011016
	for <linux-mm@kvack.org>; Thu, 28 May 2015 05:52:56 -0600
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: [PATCH 0/5] Remove s390 sw-emulated hugepages and cleanup 
Date: Thu, 28 May 2015 13:52:32 +0200
Message-Id: <1432813957-46874-1-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, James Hogan <james.hogan@imgtec.com>, Ralf Baechle <ralf@linux-mips.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@ezchip.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Zhang Zhen <zhenzhang.zhang@huawei.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Nathan Lynch <nathan_lynch@mentor.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Andy Lutomirski <luto@amacapital.net>, Michael Holzheu <holzheu@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Paolo Bonzini <pbonzini@redhat.com>, "Jason J. Herne" <jjherne@linux.vnet.ibm.com>, Davidlohr Bueso <dave@stgolabs.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Luiz Capitulino <lcapitulino@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org

Hi everyone,

there is a potential bug with KVM and hugetlbfs if the hardware does not
support hugepages (EDAT1).
We fix this by making EDAT1 a hard requirement for hugepages and 
therefore removing and simplifying code.

As s390, with the sw-emulated hugepages, was the only user of arch_prepare/release_hugepage
I also removed theses calls from common and other architecture code.

Thanks,
    Dominik

Dominik Dingel (5):
  s390/mm: make hugepages_supported a boot time decision
  mm/hugetlb: remove unused arch hook prepare/release_hugepage
  mm/hugetlb: remove arch_prepare/release_hugepage from arch headers
  s390/hugetlb: remove dead code for sw emulated huge pages
  s390/mm: forward check for huge pmds to pmd_large()

 arch/arm/include/asm/hugetlb.h     |  9 ------
 arch/arm64/include/asm/hugetlb.h   |  9 ------
 arch/ia64/include/asm/hugetlb.h    |  9 ------
 arch/metag/include/asm/hugetlb.h   |  9 ------
 arch/mips/include/asm/hugetlb.h    |  9 ------
 arch/powerpc/include/asm/hugetlb.h |  9 ------
 arch/s390/include/asm/hugetlb.h    |  3 --
 arch/s390/include/asm/page.h       |  8 ++---
 arch/s390/kernel/setup.c           |  2 ++
 arch/s390/mm/hugetlbpage.c         | 65 +++-----------------------------------
 arch/s390/mm/pgtable.c             |  2 ++
 arch/sh/include/asm/hugetlb.h      |  9 ------
 arch/sparc/include/asm/hugetlb.h   |  9 ------
 arch/tile/include/asm/hugetlb.h    |  9 ------
 arch/x86/include/asm/hugetlb.h     |  9 ------
 mm/hugetlb.c                       | 10 ------
 16 files changed, 12 insertions(+), 168 deletions(-)

-- 
2.3.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
