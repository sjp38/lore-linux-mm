Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id EA9DE6B0257
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 10:44:06 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so166847521wib.0
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 07:44:06 -0700 (PDT)
Received: from mail-wi0-x229.google.com (mail-wi0-x229.google.com. [2a00:1450:400c:c05::229])
        by mx.google.com with ESMTPS id b12si2875722wjb.139.2015.07.22.07.44.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 07:44:05 -0700 (PDT)
Received: by wibxm9 with SMTP id xm9so166846378wib.0
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 07:44:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1437561037-31995-1-git-send-email-a.ryabinin@samsung.com>
References: <1437561037-31995-1-git-send-email-a.ryabinin@samsung.com>
Date: Wed, 22 Jul 2015 17:44:04 +0300
Message-ID: <CALW4P++_T3FtBDGzZV+ez6HuqsEH3cEP-_g-RF7PWAqHPUaP-A@mail.gmail.com>
Subject: Re: [PATCH v3 0/5] KASAN for arm64
From: Alexey Klimov <klimov.linux@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Linus Walleij <linus.walleij@linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>

On Wed, Jul 22, 2015 at 1:30 PM, Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
> For git users patches are available in git:
>         git://github.com/aryabinin/linux.git kasan/arm64v3
>
> Changes since v2:
>  - Rebase on top of v4.2-rc3
>  - Address feedback from Catalin.
>  - Print memory assignment fro Linus

from?

>  - Add message about KASAN being initialized
>
> Changes since v1:
>  - Address feedback from Catalin.
>  - Generalize some kasan init code from arch/x86/mm/kasan_init_64.c
>     and reuse it for arm64.
>  - Some bugfixes, including:
>         add missing arm64/include/asm/kasan.h
>         add tlb flush after changing ttbr1
>  - Add code comments.
>
>
> Andrey Ryabinin (4):
>   mm: kasan: introduce generic kasan_populate_zero_shadow()
>   arm64: introduce VA_START macro - the first kernel virtual address.
>   arm64: move PGD_SIZE definition to pgalloc.h
>   arm64: add KASAN support
>
> Linus Walleij (1):
>   ARM64: kasan: print memory assignment
>
>  arch/arm64/Kconfig               |  17 ++++
>  arch/arm64/include/asm/kasan.h   |  24 ++++++
>  arch/arm64/include/asm/memory.h  |   2 +
>  arch/arm64/include/asm/pgalloc.h |   1 +
>  arch/arm64/include/asm/pgtable.h |   9 +-
>  arch/arm64/include/asm/string.h  |  16 ++++
>  arch/arm64/kernel/arm64ksyms.c   |   3 +
>  arch/arm64/kernel/head.S         |   3 +
>  arch/arm64/kernel/module.c       |  16 +++-
>  arch/arm64/kernel/setup.c        |   2 +
>  arch/arm64/lib/memcpy.S          |   3 +
>  arch/arm64/lib/memmove.S         |   7 +-
>  arch/arm64/lib/memset.S          |   3 +
>  arch/arm64/mm/Makefile           |   3 +
>  arch/arm64/mm/init.c             |   6 ++
>  arch/arm64/mm/kasan_init.c       | 176 +++++++++++++++++++++++++++++++++++++++
>  arch/arm64/mm/pgd.c              |   2 -
>  arch/x86/mm/kasan_init_64.c      |   8 +-
>  include/linux/kasan.h            |   8 ++
>  mm/kasan/Makefile                |   2 +-
>  mm/kasan/kasan_init.c            | 142 +++++++++++++++++++++++++++++++
>  21 files changed, 440 insertions(+), 13 deletions(-)
>  create mode 100644 arch/arm64/include/asm/kasan.h
>  create mode 100644 arch/arm64/mm/kasan_init.c
>  create mode 100644 mm/kasan/kasan_init.c

Could you please check license header in all new files?
By the way, i don't remember if checkpatch can detect missing GPL header.


Best regards,
Alexey Klimov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
