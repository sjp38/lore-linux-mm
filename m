Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7989C6B0297
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 06:05:02 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id l21so220900377ioi.2
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 03:05:02 -0700 (PDT)
Received: from mail-io0-x243.google.com (mail-io0-x243.google.com. [2607:f8b0:4001:c06::243])
        by mx.google.com with ESMTPS id t70si10857792itb.60.2017.04.24.03.05.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 03:05:01 -0700 (PDT)
Received: by mail-io0-x243.google.com with SMTP id k87so47499393ioi.0
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 03:05:01 -0700 (PDT)
From: Oliver O'Halloran <oohall@gmail.com>
Subject: [resend PATCH v2] mm, x86: Add ARCH_HAS_ZONE_DEVICE to Kconfig
Date: Mon, 24 Apr 2017 20:04:34 +1000
Message-Id: <20170424100434.890-1-oohall@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: Oliver O'Halloran <oohall@gmail.com>, linux-mm@kvack.org

Currently ZONE_DEVICE depends on X86_64 and this will get unwieldly as
new architectures (and platforms) get ZONE_DEVICE support. Move to an
arch selected Kconfig option to save us the trouble.

Cc: x86@kernel.org
Cc: linux-mm@kvack.org
Signed-off-by: Oliver O'Halloran <oohall@gmail.com>
---
v2: Added missing hunk.
---
 arch/x86/Kconfig | 1 +
 mm/Kconfig       | 5 ++++-
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index a694d0002758..84ac36ca3b42 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -58,6 +58,7 @@ config X86
 	select ARCH_HAS_STRICT_KERNEL_RWX
 	select ARCH_HAS_STRICT_MODULE_RWX
 	select ARCH_HAS_UBSAN_SANITIZE_ALL
+	select ARCH_HAS_ZONE_DEVICE		if X86_64
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
 	select ARCH_MIGHT_HAVE_ACPI_PDC		if ACPI
 	select ARCH_MIGHT_HAVE_PC_PARPORT
diff --git a/mm/Kconfig b/mm/Kconfig
index 9b8fccb969dc..4282bee2731c 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -684,12 +684,15 @@ config IDLE_PAGE_TRACKING
 
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
