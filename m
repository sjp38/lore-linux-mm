Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id CE0E26B007D
	for <linux-mm@kvack.org>; Sun, 15 Sep 2013 06:01:38 -0400 (EDT)
From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH TRIVIAL] mm/Kconfig: Grammar s/an/a/
Date: Sun, 15 Sep 2013 12:01:33 +0200
Message-Id: <1379239293-8272-1-git-send-email-geert@linux-m68k.org>
In-Reply-To: <y>
References: <y>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <trivial@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 mm/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 026771a..ff6e820 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -20,7 +20,7 @@ config FLATMEM_MANUAL
 
 	  Some users of more advanced features like NUMA and
 	  memory hotplug may have different options here.
-	  DISCONTIGMEM is an more mature, better tested system,
+	  DISCONTIGMEM is a more mature, better tested system,
 	  but is incompatible with memory hotplug and may suffer
 	  decreased performance over SPARSEMEM.  If unsure between
 	  "Sparse Memory" and "Discontiguous Memory", choose
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
