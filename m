Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id AC7346B025F
	for <linux-mm@kvack.org>; Sat,  9 Apr 2016 17:06:28 -0400 (EDT)
Received: by mail-pf0-f173.google.com with SMTP id n1so97261407pfn.2
        for <linux-mm@kvack.org>; Sat, 09 Apr 2016 14:06:28 -0700 (PDT)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id bw8si9238602pad.127.2016.04.09.14.06.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Apr 2016 14:06:28 -0700 (PDT)
Received: by mail-pa0-x242.google.com with SMTP id k3so7716222pav.3
        for <linux-mm@kvack.org>; Sat, 09 Apr 2016 14:06:27 -0700 (PDT)
From: Rui Salvaterra <rsalvaterra@gmail.com>
Subject: [PATCH v2 2/2] lib: lz4: cleanup unaligned access efficiency detection
Date: Sat,  9 Apr 2016 22:05:35 +0100
Message-Id: <1460235935-1003-3-git-send-email-rsalvaterra@gmail.com>
In-Reply-To: <1460235935-1003-1-git-send-email-rsalvaterra@gmail.com>
References: <1460235935-1003-1-git-send-email-rsalvaterra@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, sergey.senozhatsky@gmail.com, sergey.senozhatsky.work@gmail.com, gregkh@linuxfoundation.org, eunb.song@samsung.com, minchan@kernel.org, chanho.min@lge.com, kyungsik.lee@lge.com, Rui Salvaterra <rsalvaterra@gmail.com>

These identifiers are bogus. The interested architectures should define
HAVE_EFFICIENT_UNALIGNED_ACCESS whenever relevant to do so. If this
isn't true for some arch, it should be fixed in the arch definition.

Signed-off-by: Rui Salvaterra <rsalvaterra@gmail.com>
---
 lib/lz4/lz4defs.h | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/lib/lz4/lz4defs.h b/lib/lz4/lz4defs.h
index 0710a62..c79d7ea 100644
--- a/lib/lz4/lz4defs.h
+++ b/lib/lz4/lz4defs.h
@@ -24,9 +24,7 @@
 typedef struct _U16_S { u16 v; } U16_S;
 typedef struct _U32_S { u32 v; } U32_S;
 typedef struct _U64_S { u64 v; } U64_S;
-#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)		\
-	|| defined(CONFIG_ARM) && __LINUX_ARM_ARCH__ >= 6	\
-	&& defined(ARM_EFFICIENT_UNALIGNED_ACCESS)
+#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
 
 #define A16(x) (((U16_S *)(x))->v)
 #define A32(x) (((U32_S *)(x))->v)
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
