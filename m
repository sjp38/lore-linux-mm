Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 7CF4C6B00CD
	for <linux-mm@kvack.org>; Tue, 11 Sep 2012 12:47:23 -0400 (EDT)
From: Will Deacon <will.deacon@arm.com>
Subject: [PATCH 3/3] mm: Introduce HAVE_ARCH_TRANSPARENT_HUGEPAGE
Date: Tue, 11 Sep 2012 17:47:16 +0100
Message-Id: <1347382036-18455-4-git-send-email-will.deacon@arm.com>
In-Reply-To: <1347382036-18455-1-git-send-email-will.deacon@arm.com>
References: <1347382036-18455-1-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, akpm@linux-foundation.org, mhocko@suse.cz, Steve Capper <steve.capper@arm.com>, Will Deacon <will.deacon@arm.com>

From: Steve Capper <steve.capper@arm.com>

Different architectures have slightly different pre-requisites for supporting
Transparent Huge Pages. To simplify the layout of mm/Kconfig, a new option
HAVE_ARCH_TRANSPARENT_HUGEPAGE is introduced and set in each architecture's
Kconfig file (at the moment x86, with ARM being set in a future patch).

Signed-off-by: Steve Capper <steve.capper@arm.com>
Signed-off-by: Will Deacon <will.deacon@arm.com>
---
 arch/x86/Kconfig |    4 ++++
 mm/Kconfig       |    2 +-
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 8ec3a1a..7decdcf 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1297,6 +1297,10 @@ config ILLEGAL_POINTER_VALUE
        default 0 if X86_32
        default 0xdead000000000000 if X86_64
 
+config HAVE_ARCH_TRANSPARENT_HUGEPAGE
+       def_bool y
+       depends on MMU
+
 source "mm/Kconfig"
 
 config HIGHPTE
diff --git a/mm/Kconfig b/mm/Kconfig
index d5c8019..3322342 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -318,7 +318,7 @@ config NOMMU_INITIAL_TRIM_EXCESS
 
 config TRANSPARENT_HUGEPAGE
 	bool "Transparent Hugepage Support"
-	depends on X86 && MMU
+	depends on HAVE_ARCH_TRANSPARENT_HUGEPAGE
 	select COMPACTION
 	help
 	  Transparent Hugepages allows the kernel to use huge pages and
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
