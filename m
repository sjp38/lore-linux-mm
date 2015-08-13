Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 958886B0038
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 01:37:43 -0400 (EDT)
Received: by lbbtg9 with SMTP id tg9so21214381lbb.1
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 22:37:42 -0700 (PDT)
Received: from mail-la0-x231.google.com (mail-la0-x231.google.com. [2a00:1450:4010:c03::231])
        by mx.google.com with ESMTPS id dp7si1135348lbc.155.2015.08.12.22.37.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Aug 2015 22:37:41 -0700 (PDT)
Received: by lagz9 with SMTP id z9so20273562lag.3
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 22:37:41 -0700 (PDT)
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Subject: [PATCH 0/2] x86/KASAN updates for 4.3
Date: Thu, 13 Aug 2015 08:37:22 +0300
Message-Id: <1439444244-26057-1-git-send-email-ryabinin.a.a@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Arnd Bergmann <arnd@arndb.de>, Linus Walleij <linus.walleij@linaro.org>, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexey Klimov <klimov.linux@gmail.com>, Yury <yury.norov@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

These 2 patches taken from v5 'KASAN for arm64' series.
The only change is updated changelog in second patch.

I hope this is not too late to queue these for 4.3,
as this allow us to merge arm64/KASAN patches in v4.4
through arm64 tree.



Andrey Ryabinin (2):
  x86/kasan: define KASAN_SHADOW_OFFSET per architecture
  x86/kasan, mm: introduce generic kasan_populate_zero_shadow()

 arch/x86/include/asm/kasan.h |   3 +
 arch/x86/mm/kasan_init_64.c  | 123 ++--------------------------------
 include/linux/kasan.h        |  10 ++-
 mm/kasan/Makefile            |   2 +-
 mm/kasan/kasan_init.c        | 152 +++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 170 insertions(+), 120 deletions(-)
 create mode 100644 mm/kasan/kasan_init.c

-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
