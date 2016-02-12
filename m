Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 8FCF36B0255
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 18:50:35 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id yy13so53868304pab.3
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 15:50:35 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id tt2si23039533pac.167.2016.02.12.15.50.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Feb 2016 15:50:34 -0800 (PST)
Received: by mail-pa0-x22d.google.com with SMTP id ho8so54243771pac.2
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 15:50:34 -0800 (PST)
From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH] mm/Kconfig: remove redundant arch depend for memory hotplug
Date: Fri, 12 Feb 2016 15:27:47 -0800
Message-Id: <1455319667-12112-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, yang.shi@linaro.org

MEMORY_HOTPLUG already depends on ARCH_ENABLE_MEMORY_HOTPLUG which is selected
by the supported architectures, so the following arch depend is unnecessary.

Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
 mm/Kconfig | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 03cbfa0..c077765 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -187,7 +187,6 @@ config MEMORY_HOTPLUG
 	bool "Allow for memory hot-add"
 	depends on SPARSEMEM || X86_64_ACPI_NUMA
 	depends on ARCH_ENABLE_MEMORY_HOTPLUG
-	depends on (IA64 || X86 || PPC_BOOK3S_64 || SUPERH || S390)
 
 config MEMORY_HOTPLUG_SPARSE
 	def_bool y
-- 
2.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
