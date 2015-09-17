Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id D3FF482F64
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 05:38:29 -0400 (EDT)
Received: by lagj9 with SMTP id j9so7614928lag.2
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 02:38:29 -0700 (PDT)
Received: from mail-la0-x22f.google.com (mail-la0-x22f.google.com. [2a00:1450:4010:c03::22f])
        by mx.google.com with ESMTPS id v4si1655083lae.75.2015.09.17.02.38.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Sep 2015 02:38:28 -0700 (PDT)
Received: by lanb10 with SMTP id b10so7527858lan.3
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 02:38:28 -0700 (PDT)
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Subject: [PATCH v6 6/6] Documentation/features/KASAN: arm64 supports KASAN now
Date: Thu, 17 Sep 2015 12:38:12 +0300
Message-Id: <1442482692-6416-7-git-send-email-ryabinin.a.a@gmail.com>
In-Reply-To: <1442482692-6416-1-git-send-email-ryabinin.a.a@gmail.com>
References: <1442482692-6416-1-git-send-email-ryabinin.a.a@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-arm-kernel@lists.infradead.org
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Linus Walleij <linus.walleij@linaro.org>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org, David Keitel <dkeitel@codeaurora.org>, linux-mm@kvack.org, Alexey Klimov <klimov.linux@gmail.com>, Yury <yury.norov@gmail.com>, Andrey Konovalov <andreyknvl@google.com>

Signed-off-by: Andrey Ryabinin <ryabinin.a.a@gmail.com>
---
 Documentation/features/debug/KASAN/arch-support.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/features/debug/KASAN/arch-support.txt b/Documentation/features/debug/KASAN/arch-support.txt
index 14531da..703f578 100644
--- a/Documentation/features/debug/KASAN/arch-support.txt
+++ b/Documentation/features/debug/KASAN/arch-support.txt
@@ -9,7 +9,7 @@
     |       alpha: | TODO |
     |         arc: | TODO |
     |         arm: | TODO |
-    |       arm64: | TODO |
+    |       arm64: |  ok  |
     |       avr32: | TODO |
     |    blackfin: | TODO |
     |         c6x: | TODO |
-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
