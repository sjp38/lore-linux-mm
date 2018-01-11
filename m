Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7D6886B026E
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 10:29:18 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id 61so1673854wrg.9
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 07:29:18 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f4sor304711wmd.91.2018.01.11.07.29.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Jan 2018 07:29:17 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH 0/2] kasan: a few cleanups
Date: Thu, 11 Jan 2018 16:29:07 +0100
Message-Id: <cover.1515684162.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-kernel@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Andrey Konovalov <andreyknvl@google.com>

Clean up usage of KASAN_SHADOW_SCALE_SHIFT and fix prototype author email
address.

Andrey Konovalov (2):
  kasan: fix prototype author email address
  kasan: clean up KASAN_SHADOW_SCALE_SHIFT usage

 arch/arm64/include/asm/kasan.h  | 3 ++-
 arch/arm64/include/asm/memory.h | 3 ++-
 arch/arm64/mm/kasan_init.c      | 3 ++-
 arch/x86/include/asm/kasan.h    | 8 ++++++--
 include/linux/kasan.h           | 2 --
 mm/kasan/kasan.c                | 2 +-
 mm/kasan/report.c               | 2 +-
 7 files changed, 14 insertions(+), 9 deletions(-)

-- 
2.16.0.rc1.238.g530d649a79-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
