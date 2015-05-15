Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f177.google.com (mail-ie0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 9B46F6B0032
	for <linux-mm@kvack.org>; Fri, 15 May 2015 09:59:19 -0400 (EDT)
Received: by iesa3 with SMTP id a3so25108580ies.2
        for <linux-mm@kvack.org>; Fri, 15 May 2015 06:59:19 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id wy7si2720286pab.113.2015.05.15.06.59.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 15 May 2015 06:59:18 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NOE00F4C9IPRE80@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 15 May 2015 14:59:13 +0100 (BST)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v2 0/5] KASan for arm64
Date: Fri, 15 May 2015 16:58:59 +0300
Message-id: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, David Keitel <dkeitel@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Andrey Ryabinin <a.ryabinin@samsung.com>

The second iteration of kasan for arm64.

Patches available in git:
	git://github.com/aryabinin/linux.git kasan/arm64v2

Changes since v1:
 - Address feedback from Catalin.
 - Generalize some kasan init code from arch/x86/mm/kasan_init_64.c
    and reuse it for arm64.
 - Some bugfixes, including:
   	add missing arm64/include/asm/kasan.h
	add tlb flush after changing ttbr1
 - Add code comments.

Andrey Ryabinin (5):
  kasan, x86: move KASAN_SHADOW_OFFSET to the arch Kconfig
  x86: kasan: fix types in kasan page tables declarations
  x86: kasan: generalize populate_zero_shadow() code
  kasan, x86: move populate_zero_shadow() out of arch directory
  arm64: add KASan support

 arch/arm64/Kconfig                   |   7 ++
 arch/arm64/include/asm/kasan.h       |  24 ++++++
 arch/arm64/include/asm/pgtable.h     |   7 ++
 arch/arm64/include/asm/string.h      |  16 ++++
 arch/arm64/include/asm/thread_info.h |   8 ++
 arch/arm64/kernel/head.S             |   3 +
 arch/arm64/kernel/module.c           |  16 +++-
 arch/arm64/kernel/setup.c            |   2 +
 arch/arm64/lib/memcpy.S              |   3 +
 arch/arm64/lib/memmove.S             |   7 +-
 arch/arm64/lib/memset.S              |   3 +
 arch/arm64/mm/Makefile               |   3 +
 arch/arm64/mm/kasan_init.c           | 143 +++++++++++++++++++++++++++++++++++
 arch/x86/Kconfig                     |   4 +
 arch/x86/include/asm/kasan.h         |  10 +--
 arch/x86/mm/kasan_init_64.c          | 110 ++-------------------------
 include/linux/kasan.h                |   8 ++
 lib/Kconfig.kasan                    |   4 -
 mm/kasan/Makefile                    |   2 +-
 mm/kasan/kasan_init.c                | 136 +++++++++++++++++++++++++++++++++
 20 files changed, 396 insertions(+), 120 deletions(-)
 create mode 100644 arch/arm64/include/asm/kasan.h
 create mode 100644 arch/arm64/mm/kasan_init.c
 create mode 100644 mm/kasan/kasan_init.c

-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
