Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id 42E7F82F65
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 11:53:03 -0400 (EDT)
Received: by lbwr8 with SMTP id r8so145858671lbw.2
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 08:53:02 -0700 (PDT)
Received: from mail-lb0-x236.google.com (mail-lb0-x236.google.com. [2a00:1450:4010:c04::236])
        by mx.google.com with ESMTPS id sc1si11661826lbb.8.2015.10.12.08.52.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Oct 2015 08:52:59 -0700 (PDT)
Received: by lbbck17 with SMTP id ck17so27179413lbb.1
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 08:52:59 -0700 (PDT)
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Subject: [PATCH v7 4/4] Documentation/features/KASAN: arm64 supports KASAN now
Date: Mon, 12 Oct 2015 18:53:00 +0300
Message-Id: <1444665180-301-5-git-send-email-ryabinin.a.a@gmail.com>
In-Reply-To: <1444665180-301-1-git-send-email-ryabinin.a.a@gmail.com>
References: <1444665180-301-1-git-send-email-ryabinin.a.a@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-arm-kernel@lists.infradead.org
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Linus Walleij <linus.walleij@linaro.org>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org, David Keitel <dkeitel@codeaurora.org>, linux-mm@kvack.org, kasan-dev <kasan-dev@googlegroups.com>, Alexey Klimov <klimov.linux@gmail.com>, Yury <yury.norov@gmail.com>, Andrey Konovalov <andreyknvl@google.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>

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
2.4.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
