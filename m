Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id B63296B0008
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 09:57:28 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id w2so5946319qti.8
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 06:57:28 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id j186si287056qkd.386.2018.04.09.06.57.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Apr 2018 06:57:27 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w39DuFo2140525
	for <linux-mm@kvack.org>; Mon, 9 Apr 2018 09:57:26 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2h88dabq26-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 09 Apr 2018 09:57:25 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 9 Apr 2018 14:57:20 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH 0/3] move __HAVE_ARCH_PTE_SPECIAL in Kconfig
Date: Mon,  9 Apr 2018 15:57:06 +0200
Message-Id: <1523282229-20731-1-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Jerome Glisse <jglisse@redhat.com>, mhocko@kernel.org, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Vineet Gupta <vgupta@synopsys.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <albert@sifive.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

The per architecture __HAVE_ARCH_PTE_SPECIAL is defined statically in the
per architecture header files. This doesn't allow to make other
configuration dependent on it.

This series is moving the __HAVE_ARCH_PTE_SPECIAL into the Kconfig files,
setting it automatically when architectures was already setting it in
header file.

There is no functional change introduced by this series.

Laurent Dufour (3):
  mm: introduce ARCH_HAS_PTE_SPECIAL
  mm: replace __HAVE_ARCH_PTE_SPECIAL
  mm: remove __HAVE_ARCH_PTE_SPECIAL

 Documentation/features/vm/pte_special/arch-support.txt | 2 +-
 arch/arc/Kconfig                                       | 1 +
 arch/arc/include/asm/pgtable.h                         | 2 --
 arch/arm/Kconfig                                       | 1 +
 arch/arm/include/asm/pgtable-3level.h                  | 1 -
 arch/arm64/Kconfig                                     | 1 +
 arch/arm64/include/asm/pgtable.h                       | 2 --
 arch/powerpc/Kconfig                                   | 1 +
 arch/powerpc/include/asm/book3s/64/pgtable.h           | 3 ---
 arch/powerpc/include/asm/pte-common.h                  | 3 ---
 arch/riscv/Kconfig                                     | 1 +
 arch/s390/Kconfig                                      | 1 +
 arch/s390/include/asm/pgtable.h                        | 1 -
 arch/sh/Kconfig                                        | 1 +
 arch/sh/include/asm/pgtable.h                          | 2 --
 arch/sparc/Kconfig                                     | 1 +
 arch/sparc/include/asm/pgtable_64.h                    | 3 ---
 arch/x86/Kconfig                                       | 1 +
 arch/x86/include/asm/pgtable_types.h                   | 1 -
 include/linux/pfn_t.h                                  | 4 ++--
 mm/Kconfig                                             | 3 +++
 mm/gup.c                                               | 4 ++--
 mm/memory.c                                            | 2 +-
 23 files changed, 18 insertions(+), 24 deletions(-)

-- 
2.7.4
