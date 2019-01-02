Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id E3E228E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 12:36:14 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id w16so14840985wrk.10
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 09:36:14 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q10sor27086318wro.14.2019.01.02.09.36.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 09:36:13 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v2 0/3] kasan: tag-based mode fixes
Date: Wed,  2 Jan 2019 18:36:05 +0100
Message-Id: <cover.1546450432.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vincenzo Frascino <vincenzo.frascino@arm.com>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>, Andrey Konovalov <andreyknvl@google.com>

Hi Andrew,

This patchset includes an updated "kasan, arm64: use ARCH_SLAB_MINALIGN
instead of manual aligning" patch and fixes for two more issues that
were uncovered while testing with a variety of different config options
enabled.

Thanks!

Andrey Konovalov (3):
  kasan, arm64: use ARCH_SLAB_MINALIGN instead of manual aligning
  kasan: make tag based mode work with CONFIG_HARDENED_USERCOPY
  kasan: fix krealloc handling for tag-based mode

 arch/arm64/include/asm/kasan.h |  4 ++++
 include/linux/kasan.h          | 14 +++++---------
 include/linux/slab.h           |  5 +++--
 mm/kasan/common.c              | 22 ++++++++++++----------
 mm/slab.c                      |  8 ++++----
 mm/slab_common.c               |  2 +-
 mm/slub.c                      | 12 +++++++-----
 7 files changed, 36 insertions(+), 31 deletions(-)

-- 
2.20.1.415.g653613c723-goog
