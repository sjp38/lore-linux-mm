Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 7EF696B0265
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 10:48:16 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so10955276wic.1
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 07:48:16 -0700 (PDT)
Received: from mail-wi0-x22d.google.com (mail-wi0-x22d.google.com. [2a00:1450:400c:c05::22d])
        by mx.google.com with ESMTPS id p17si11308429wie.89.2015.09.03.07.48.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Sep 2015 07:48:10 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so22613018wic.1
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 07:48:09 -0700 (PDT)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH 6/7] kasan: move KASAN_SANITIZE in arch/x86/boot/Makefile
Date: Thu,  3 Sep 2015 16:47:41 +0200
Message-Id: <9a748d03d5a1dc5d18e69f8aff7073352ca310e3.1441290220.git.andreyknvl@google.com>
In-Reply-To: <cover.1441290219.git.andreyknvl@google.com>
References: <cover.1441290219.git.andreyknvl@google.com>
In-Reply-To: <cover.1441290219.git.andreyknvl@google.com>
References: <cover.1441290219.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rusty Russell <rusty@rustcorp.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: dvyukov@google.com, glider@google.com, kcc@google.com, Andrey Konovalov <andreyknvl@google.com>

Move KASAN_SANITIZE in arch/x86/boot/Makefile above the comment
related to SVGA_MODE, since the comment refers to 'the next line'.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 arch/x86/boot/Makefile | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/x86/boot/Makefile b/arch/x86/boot/Makefile
index 0d553e5..2ee62db 100644
--- a/arch/x86/boot/Makefile
+++ b/arch/x86/boot/Makefile
@@ -9,13 +9,13 @@
 # Changed by many, many contributors over the years.
 #
 
+KASAN_SANITIZE := n
+
 # If you want to preset the SVGA mode, uncomment the next line and
 # set SVGA_MODE to whatever number you want.
 # Set it to -DSVGA_MODE=NORMAL_VGA if you just want the EGA/VGA mode.
 # The number is the same as you would ordinarily press at bootup.
 
-KASAN_SANITIZE := n
-
 SVGA_MODE	:= -DSVGA_MODE=NORMAL_VGA
 
 targets		:= vmlinux.bin setup.bin setup.elf bzImage
-- 
2.5.0.457.gab17608

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
