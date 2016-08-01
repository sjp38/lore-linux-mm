Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id E4B276B0262
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 11:09:37 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id v184so254976934qkc.0
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 08:09:37 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id f51si20250325qtc.97.2016.08.01.08.09.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 01 Aug 2016 08:09:37 -0700 (PDT)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH] mm: add restriction when memory_hotplug config enable
Date: Mon, 1 Aug 2016 23:00:51 +0800
Message-ID: <1470063651-29519-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org

From: zhong jiang <zhongjiang@huawei.com>

At present, It is obvious that memory online and offline will fail
when KASAN enable,  therefore, it is necessary to add the condition
to limit the memory_hotplug when KASAN enable.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 mm/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/Kconfig b/mm/Kconfig
index 3e2daef..f6dd77e 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -187,6 +187,7 @@ config MEMORY_HOTPLUG
 	bool "Allow for memory hot-add"
 	depends on SPARSEMEM || X86_64_ACPI_NUMA
 	depends on ARCH_ENABLE_MEMORY_HOTPLUG
+	depends on !KASAN
 
 config MEMORY_HOTPLUG_SPARSE
 	def_bool y
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
