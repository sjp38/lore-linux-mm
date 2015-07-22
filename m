Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 642AA9003C7
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 06:30:51 -0400 (EDT)
Received: by pachj5 with SMTP id hj5so136546090pac.3
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 03:30:51 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id mc7si2801830pdb.169.2015.07.22.03.30.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Jul 2015 03:30:50 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NRV00H4CX7AW960@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 22 Jul 2015 11:30:46 +0100 (BST)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v3 0/5] KASAN for arm64
Date: Wed, 22 Jul 2015 13:30:32 +0300
Message-id: <1437561037-31995-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, David Keitel <dkeitel@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Linus Walleij <linus.walleij@linaro.org>, Andrey Ryabinin <a.ryabinin@samsung.com>, linux-kernel@vger.kernel.org

For git users patches are available in git:
 	git://github.com/aryabinin/linux.git kasan/arm64v3

Changes since v2:
 - Rebase on top of v4.2-rc3
 - Address feedback from Catalin.
 - Print memory assignment fro Linus
 - Add message about KASAN being initialized

Changes since v1:
 - Address feedback from Catalin.
 - Generalize some kasan init code from arch/x86/mm/kasan_init_64.c
    and reuse it for arm64.
 - Some bugfixes, including:
   	add missing arm64/include/asm/kasan.h
	add tlb flush after changing ttbr1
 - Add code comments.


Andrey Ryabinin (4):
  mm: kasan: introduce generic kasan_populate_zero_shadow()
  arm64: introduce VA_START macro - the first kernel virtual address.
  arm64: move PGD_SIZE definition to pgalloc.h
  arm64: add KASAN support

Linus Walleij (1):
  ARM64: kasan: print memory assignment

 arch/arm64/Kconfig               |  17 ++++
 arch/arm64/include/asm/kasan.h   |  24 ++++++
 arch/arm64/include/asm/memory.h  |   2 +
 arch/arm64/include/asm/pgalloc.h |   1 +
 arch/arm64/include/asm/pgtable.h |   9 +-
 arch/arm64/include/asm/string.h  |  16 ++++
 arch/arm64/kernel/arm64ksyms.c   |   3 +
 arch/arm64/kernel/head.S         |   3 +
 arch/arm64/kernel/module.c       |  16 +++-
 arch/arm64/kernel/setup.c        |   2 +
 arch/arm64/lib/memcpy.S          |   3 +
 arch/arm64/lib/memmove.S         |   7 +-
 arch/arm64/lib/memset.S          |   3 +
 arch/arm64/mm/Makefile           |   3 +
 arch/arm64/mm/init.c             |   6 ++
 arch/arm64/mm/kasan_init.c       | 176 +++++++++++++++++++++++++++++++++++++++
 arch/arm64/mm/pgd.c              |   2 -
 arch/x86/mm/kasan_init_64.c      |   8 +-
 include/linux/kasan.h            |   8 ++
 mm/kasan/Makefile                |   2 +-
 mm/kasan/kasan_init.c            | 142 +++++++++++++++++++++++++++++++
 21 files changed, 440 insertions(+), 13 deletions(-)
 create mode 100644 arch/arm64/include/asm/kasan.h
 create mode 100644 arch/arm64/mm/kasan_init.c
 create mode 100644 mm/kasan/kasan_init.c

-- 
2.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
