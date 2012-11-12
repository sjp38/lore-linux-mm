Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id C54726B0089
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 11:34:24 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so754815pbc.14
        for <linux-mm@kvack.org>; Mon, 12 Nov 2012 08:34:24 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 2/4] avr32, kconfig: remove HAVE_ARCH_BOOTMEM
Date: Tue, 13 Nov 2012 01:31:53 +0900
Message-Id: <1352737915-30906-2-git-send-email-js1304@gmail.com>
In-Reply-To: <1352737915-30906-1-git-send-email-js1304@gmail.com>
References: <1352737915-30906-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>, Haavard Skinnemoen <hskinnemoen@gmail.com>, Hans-Christian Egtvedt <egtvedt@samfundet.no>

Now, there is no code for CONFIG_HAVE_ARCH_BOOTMEM.
So remove it.

Cc: Haavard Skinnemoen <hskinnemoen@gmail.com>
Cc: Hans-Christian Egtvedt <egtvedt@samfundet.no>
Signed-off-by: Joonsoo Kim <js1304@gmail.com>

diff --git a/arch/avr32/Kconfig b/arch/avr32/Kconfig
index 06e73bf..c2bbc9a 100644
--- a/arch/avr32/Kconfig
+++ b/arch/avr32/Kconfig
@@ -193,9 +193,6 @@ source "kernel/Kconfig.preempt"
 config QUICKLIST
 	def_bool y
 
-config HAVE_ARCH_BOOTMEM
-	def_bool n
-
 config ARCH_HAVE_MEMORY_PRESENT
 	def_bool n
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
