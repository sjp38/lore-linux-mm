Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 738CD6B000A
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 12:23:32 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id t83-v6so6423175wmt.3
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 09:23:32 -0700 (PDT)
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id v21-v6si22276720wrc.122.2018.07.13.09.23.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 09:23:31 -0700 (PDT)
Message-Id: <cover.1531498345.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [RFC PATCH v1 0/4] KASAN for nohash PPC32
Date: Fri, 13 Jul 2018 16:23:29 +0000 (UTC)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, npiggin@gmail.com, aneesh.kumar@linux.ibm.com
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

This serie adds support to nohash PPC32

Tested on MPC8xx

Christophe Leroy (4):
  powerpc/mm: prepare kernel for KAsan on PPC32
  powerpc: add missing header in pgtable-types.h
  powerpc/32: Move early_init() in a separate file
  powerpc/nohash32: Add KASAN support

 arch/powerpc/Kconfig                         |  1 +
 arch/powerpc/include/asm/kasan.h             | 21 ++++++++
 arch/powerpc/include/asm/nohash/32/pgtable.h |  2 +
 arch/powerpc/include/asm/pgtable-types.h     |  2 +
 arch/powerpc/include/asm/ppc_asm.h           |  5 ++
 arch/powerpc/include/asm/setup.h             |  5 ++
 arch/powerpc/include/asm/string.h            | 14 ++++++
 arch/powerpc/kernel/Makefile                 |  5 +-
 arch/powerpc/kernel/cputable.c               |  4 +-
 arch/powerpc/kernel/early_32.c               | 35 +++++++++++++
 arch/powerpc/kernel/setup-common.c           |  2 +
 arch/powerpc/kernel/setup_32.c               | 33 ++-----------
 arch/powerpc/lib/Makefile                    |  2 +
 arch/powerpc/lib/copy_32.S                   |  9 ++--
 arch/powerpc/mm/Makefile                     |  3 ++
 arch/powerpc/mm/dump_linuxpagetables.c       |  8 +++
 arch/powerpc/mm/kasan_init.c                 | 73 ++++++++++++++++++++++++++++
 arch/powerpc/mm/mem.c                        |  4 ++
 18 files changed, 193 insertions(+), 35 deletions(-)
 create mode 100644 arch/powerpc/include/asm/kasan.h
 create mode 100644 arch/powerpc/kernel/early_32.c
 create mode 100644 arch/powerpc/mm/kasan_init.c

-- 
2.13.3
