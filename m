Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id DB4686B0072
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 10:49:24 -0400 (EDT)
Received: by pacwe9 with SMTP id we9so227916635pac.1
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 07:49:24 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id bu12si5956190pdb.92.2015.03.24.07.49.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 24 Mar 2015 07:49:24 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NLQ00AKI1CSI960@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 24 Mar 2015 14:53:16 +0000 (GMT)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH 0/2] KASan for arm64
Date: Tue, 24 Mar 2015 17:49:02 +0300
Message-id: <1427208544-8232-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrey Ryabinin <a.ryabinin@samsung.com>

Hi,

This adds KASan for arm64.
First patch is a small prep, all major changes in the second.

It was lightly tested in qemu.
I should get a real hardware quite soon to test this.

TODO:
	Add more interceptors for memory accessing functions (memcmp, strlen, ...),
	though this could be done later.


Andrey Ryabinin (2):
  kasan, x86: move KASAN_SHADOW_OFFSET to the arch Kconfig
  arm64: add KASan support

 arch/arm64/Kconfig                   |   7 ++
 arch/arm64/include/asm/pgtable.h     |   3 +-
 arch/arm64/include/asm/string.h      |  16 +++
 arch/arm64/include/asm/thread_info.h |   8 ++
 arch/arm64/kernel/head.S             |   3 +
 arch/arm64/kernel/module.c           |  16 ++-
 arch/arm64/kernel/setup.c            |   2 +
 arch/arm64/lib/memcpy.S              |   3 +
 arch/arm64/lib/memmove.S             |   7 +-
 arch/arm64/lib/memset.S              |   3 +
 arch/arm64/mm/Makefile               |   3 +
 arch/arm64/mm/kasan_init.c           | 211 +++++++++++++++++++++++++++++++++++
 arch/x86/Kconfig                     |   4 +
 lib/Kconfig.kasan                    |   4 -
 14 files changed, 280 insertions(+), 10 deletions(-)
 create mode 100644 arch/arm64/mm/kasan_init.c

-- 
2.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
