Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 482DF6B0075
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 18:30:08 -0500 (EST)
Received: by mail-qg0-f46.google.com with SMTP id i50so9409376qgf.5
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 15:30:08 -0800 (PST)
Received: from g5t1625.atlanta.hp.com (g5t1625.atlanta.hp.com. [15.192.137.8])
        by mx.google.com with ESMTPS id a7si15394555qam.2.2015.01.26.15.30.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jan 2015 15:30:07 -0800 (PST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [RFC PATCH 7/7] mm: Add config HUGE_IOMAP to enable huge I/O mappings
Date: Mon, 26 Jan 2015 16:13:29 -0700
Message-Id: <1422314009-31667-8-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1422314009-31667-1-git-send-email-toshi.kani@hp.com>
References: <1422314009-31667-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de, linux-mm@kvack.org
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Toshi Kani <toshi.kani@hp.com>

Add config HUGE_IOMAP to enable huge I/O mappings.  This feature
is set to Y by default when HAVE_ARCH_HUGE_VMAP is defined on the
architecture.

Note, user can also disable this feature at boot-time by the kernel
option "nohgiomap" if necessary.

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
