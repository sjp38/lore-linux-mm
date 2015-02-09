Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com [209.85.218.54])
	by kanga.kvack.org (Postfix) with ESMTP id 52A42828FD
	for <linux-mm@kvack.org>; Mon,  9 Feb 2015 17:46:07 -0500 (EST)
Received: by mail-oi0-f54.google.com with SMTP id v63so20079826oia.13
        for <linux-mm@kvack.org>; Mon, 09 Feb 2015 14:46:07 -0800 (PST)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id a10si1851551obz.72.2015.02.09.14.46.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Feb 2015 14:46:06 -0800 (PST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v2 7/7] mm: Add config HUGE_IOMAP to enable huge I/O mappings
Date: Mon,  9 Feb 2015 15:45:35 -0700
Message-Id: <1423521935-17454-8-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1423521935-17454-1-git-send-email-toshi.kani@hp.com>
References: <1423521935-17454-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Elliott@hp.com, Toshi Kani <toshi.kani@hp.com>

Add config HUGE_IOMAP to enable huge I/O mappings.  This feature
is set to Y by default when HAVE_ARCH_HUGE_VMAP is defined on the
architecture.

Note that user can also disable this feature at boot-time by the
new kernel option "nohugeiomap" when necessary.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 mm/Kconfig |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/mm/Kconfig b/mm/Kconfig
index 1d1ae6b..eb738ae 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -444,6 +444,17 @@ choice
 	  benefit.
 endchoice
 
+config HUGE_IOMAP
+	bool "Kernel huge I/O mapping support"
+	depends on HAVE_ARCH_HUGE_VMAP
+	default y
+	help
+	  Kernel huge I/O mapping allows the kernel to transparently
+	  create I/O mappings with huge pages for memory-mapped I/O
+	  devices whenever possible.  This feature can improve
+	  performance of certain devices with large memory size, such
+	  as NVM, and reduce the time to create their mappings.
+
 #
 # UP and nommu archs use km based percpu allocator
 #

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
