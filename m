Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 321A46B02F4
	for <linux-mm@kvack.org>; Tue, 23 May 2017 00:05:48 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c6so151300933pfj.5
        for <linux-mm@kvack.org>; Mon, 22 May 2017 21:05:48 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id v2si19693434plk.313.2017.05.22.21.05.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 21:05:47 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id u26so24494412pfd.2
        for <linux-mm@kvack.org>; Mon, 22 May 2017 21:05:47 -0700 (PDT)
From: Oliver O'Halloran <oohall@gmail.com>
Subject: [PATCH 5/6] mm, x86: Add ARCH_HAS_ZONE_DEVICE
Date: Tue, 23 May 2017 14:05:23 +1000
Message-Id: <20170523040524.13717-5-oohall@gmail.com>
In-Reply-To: <20170523040524.13717-1-oohall@gmail.com>
References: <20170523040524.13717-1-oohall@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: linux-mm@kvack.org, Oliver O'Halloran <oohall@gmail.com>, x86@kernel.org

Currently ZONE_DEVICE depends on X86_64. This is fine for now, but it
will get unwieldly as new platforms get ZONE_DEVICE support. Moving it
to an arch selected Kconfig option to save us some trouble in the
future.

Cc: x86@kernel.org
Signed-off-by: Oliver O'Halloran <oohall@gmail.com>
---
 arch/x86/Kconfig | 1 +
 mm/Kconfig       | 5 ++++-
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index cd18994a9555..acbb15234562 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -59,6 +59,7 @@ config X86
 	select ARCH_HAS_STRICT_KERNEL_RWX
 	select ARCH_HAS_STRICT_MODULE_RWX
 	select ARCH_HAS_UBSAN_SANITIZE_ALL
+	select ARCH_HAS_ZONE_DEVICE		if X86_64
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
 	select ARCH_MIGHT_HAVE_ACPI_PDC		if ACPI
 	select ARCH_MIGHT_HAVE_PC_PARPORT
diff --git a/mm/Kconfig b/mm/Kconfig
index beb7a455915d..2d38a4abe957 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -683,12 +683,15 @@ config IDLE_PAGE_TRACKING
 
 	  See Documentation/vm/idle_page_tracking.txt for more details.
 
+config ARCH_HAS_ZONE_DEVICE
+	def_bool n
+
 config ZONE_DEVICE
 	bool "Device memory (pmem, etc...) hotplug support"
 	depends on MEMORY_HOTPLUG
 	depends on MEMORY_HOTREMOVE
 	depends on SPARSEMEM_VMEMMAP
-	depends on X86_64 #arch_add_memory() comprehends device memory
+	depends on ARCH_HAS_ZONE_DEVICE
 
 	help
 	  Device memory hotplug support allows for establishing pmem,
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
