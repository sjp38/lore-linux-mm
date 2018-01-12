Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6B5766B0033
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 11:49:35 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id g13so3730002wrh.19
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 08:49:35 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v29sor9802852wra.19.2018.01.12.08.49.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Jan 2018 08:49:34 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v2 0/2] kasan: a few cleanups
Date: Fri, 12 Jan 2018 17:49:26 +0100
Message-Id: <cover.1515775666.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-kernel@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Andrey Konovalov <andreyknvl@google.com>

Clean up usage of KASAN_SHADOW_SCALE_SHIFT and fix prototype author email
address.

Changes in v2:
- fix comments as well.

Andrey Konovalov (2):
  kasan: fix prototype author email address
  kasan: clean up KASAN_SHADOW_SCALE_SHIFT usage

 arch/arm64/include/asm/kasan.h  | 17 ++++++++++-------
 arch/arm64/include/asm/memory.h |  3 ++-
 arch/arm64/mm/kasan_init.c      |  3 ++-
 arch/x86/include/asm/kasan.h    | 12 ++++++++----
 include/linux/kasan.h           |  2 --
 mm/kasan/kasan.c                |  2 +-
 mm/kasan/report.c               |  2 +-
 7 files changed, 24 insertions(+), 17 deletions(-)

-- 
2.16.0.rc1.238.g530d649a79-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
