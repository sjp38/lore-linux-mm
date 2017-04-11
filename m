Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C5C2E6B0390
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 03:52:13 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u202so136857706pgb.9
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 00:52:13 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id v1si7603576plb.242.2017.04.11.00.52.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Apr 2017 00:52:13 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id a188so3944590pfa.2
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 00:52:12 -0700 (PDT)
From: Balbir Singh <bsingharora@gmail.com>
Subject: [PATCH] mm/hmm: Fix Kconfig dependencies for HMM
Date: Tue, 11 Apr 2017 17:51:55 +1000
Message-Id: <20170411075155.845-1-bsingharora@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>

HMM uses arch_add/remove_memory, fix the Kconfig dependencies
to add MEMORY_HOTPLUG and MEMORY_HOTREMOVE

Signed-off-by: Balbir Singh <bsingharora@gmail.com>
---
 mm/Kconfig | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 43d000e..c10cd99 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -291,7 +291,7 @@ config ARCH_ENABLE_HUGEPAGE_MIGRATION
 
 config HMM
 	bool
-	depends on MMU && 64BIT
+	depends on MMU && 64BIT && MEMORY_HOTREMOVE && MEMORY_HOTPLUG
 	help
 	  HMM provides a set of helpers to share a virtual address
 	  space between CPU and a device, so that the device can access any valid
@@ -305,7 +305,7 @@ config HMM
 
 config HMM_MIRROR
 	bool "HMM mirror CPU page table into a device page table"
-	depends on MMU && 64BIT
+	depends on MMU && 64BIT && MEMORY_HOTREMOVE && MEMORY_HOTPLUG
 	select HMM
 	select MMU_NOTIFIER
 	help
@@ -317,7 +317,7 @@ config HMM_MIRROR
 
 config HMM_DEVMEM
 	bool "HMM device memory helpers (to leverage ZONE_DEVICE)"
-	depends on MMU && 64BIT
+	depends on MMU && 64BIT && MEMORY_HOTREMOVE && MEMORY_HOTPLUG
 	select HMM
 	help
 	  HMM devmem is a set of helper routines to leverage the ZONE_DEVICE
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
