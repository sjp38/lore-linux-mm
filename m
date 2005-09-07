From: Magnus Damm <magnus@valinux.co.jp>
Message-Id: <20050907071440.3015.76396.sendpatchset@cherry.local>
Subject: [PATCH] i386: CONFIG_ACPI_SRAT typo fix
Date: Wed,  7 Sep 2005 16:15:39 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Magnus Damm <magnus@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

This patch for 2.6.13-git6 fixes a typo involving CONFIG_ACPI_SRAT.

Signed-off-by: Magnus Damm <magnus@valinux.co.jp>
----

--- from-0005/include/asm-i386/mmzone.h
+++ to-0008/include/asm-i386/mmzone.h	2005-09-07 15:06:52.000000000 +0900
@@ -29,7 +29,7 @@ static inline void get_memcfg_numa(void)
 #ifdef CONFIG_X86_NUMAQ
 	if (get_memcfg_numaq())
 		return;
-#elif CONFIG_ACPI_SRAT
+#elif defined(CONFIG_ACPI_SRAT)
 	if (get_memcfg_from_srat())
 		return;
 #endif
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
