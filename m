Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id BDEBE6B0267
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 09:46:35 -0400 (EDT)
Received: by lbcjc2 with SMTP id jc2so67576797lbc.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 06:46:35 -0700 (PDT)
Received: from mail-wi0-x22d.google.com (mail-wi0-x22d.google.com. [2a00:1450:400c:c05::22d])
        by mx.google.com with ESMTPS id ld9si18739544wjc.86.2015.09.14.06.46.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 06:46:27 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so141044703wic.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 06:46:26 -0700 (PDT)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v2 6/7] kasan: move KASAN_SANITIZE in arch/x86/boot/Makefile
Date: Mon, 14 Sep 2015 15:46:07 +0200
Message-Id: <d1a8006fbdd02c31b51e39b9c931d3898d3bfee9.1442238094.git.andreyknvl@google.com>
In-Reply-To: <cover.1442238094.git.andreyknvl@google.com>
References: <cover.1442238094.git.andreyknvl@google.com>
In-Reply-To: <cover.1442238094.git.andreyknvl@google.com>
References: <cover.1442238094.git.andreyknvl@google.com>
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
2.6.0.rc0.131.gf624c3d

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
