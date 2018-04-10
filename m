Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id CAE9D6B0003
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 11:26:08 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id p21so8612687qke.20
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 08:26:08 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u16si66531qki.420.2018.04.10.08.26.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Apr 2018 08:26:06 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3AFQ2U0116043
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 11:26:05 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2h8vxh9w7x-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 11:26:04 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 10 Apr 2018 16:26:02 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v2 0/2] move __HAVE_ARCH_PTE_SPECIAL in Kconfig
Date: Tue, 10 Apr 2018 17:25:49 +0200
Message-Id: <1523373951-10981-1-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Jerome Glisse <jglisse@redhat.com>, mhocko@kernel.org, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Vineet Gupta <vgupta@synopsys.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <albert@sifive.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, David Rientjes <rientjes@google.com>

The per architecture __HAVE_ARCH_PTE_SPECIAL is defined statically in the
per architecture header files. This doesn't allow to make other
configuration dependent on it.

The first patch of this series is replacing __HAVE_ARCH_PTE_SPECIAL by
CONFIG_ARCH_HAS_PTE_SPECIAL defined into the Kconfig files,
setting it automatically when architectures was already setting it in
header file.

The second patch is removing the odd define HAVE_PTE_SPECIAL which is a
duplicate of CONFIG_ARCH_HAS_PTE_SPECIAL.

There is no functional change introduced by this series.

Laurent Dufour (2):
  mm: introduce ARCH_HAS_PTE_SPECIAL
  mm: remove odd HAVE_PTE_SPECIAL

 .../features/vm/pte_special/arch-support.txt       |  2 +-
 arch/arc/Kconfig                                   |  1 +
 arch/arc/include/asm/pgtable.h                     |  2 --
 arch/arm/Kconfig                                   |  1 +
 arch/arm/include/asm/pgtable-3level.h              |  1 -
 arch/arm64/Kconfig                                 |  1 +
 arch/arm64/include/asm/pgtable.h                   |  2 --
 arch/powerpc/Kconfig                               |  1 +
 arch/powerpc/include/asm/book3s/64/pgtable.h       |  3 ---
 arch/powerpc/include/asm/pte-common.h              |  3 ---
 arch/riscv/Kconfig                                 |  1 +
 arch/s390/Kconfig                                  |  1 +
 arch/s390/include/asm/pgtable.h                    |  1 -
 arch/sh/Kconfig                                    |  1 +
 arch/sh/include/asm/pgtable.h                      |  2 --
 arch/sparc/Kconfig                                 |  1 +
 arch/sparc/include/asm/pgtable_64.h                |  3 ---
 arch/x86/Kconfig                                   |  1 +
 arch/x86/include/asm/pgtable_types.h               |  1 -
 include/linux/pfn_t.h                              |  4 ++--
 mm/Kconfig                                         |  3 +++
 mm/gup.c                                           |  4 ++--
 mm/memory.c                                        | 23 ++++++++++------------
 23 files changed, 27 insertions(+), 36 deletions(-)

-- 
2.7.4
