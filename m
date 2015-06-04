Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id 462E7900016
	for <linux-mm@kvack.org>; Thu,  4 Jun 2015 09:14:37 -0400 (EDT)
Received: by obew15 with SMTP id w15so32150518obe.1
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 06:14:37 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id df7si1629833obb.97.2015.06.04.06.14.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 04 Jun 2015 06:14:36 -0700 (PDT)
Message-ID: <55704B0C.1000308@huawei.com>
Date: Thu, 4 Jun 2015 20:56:44 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC PATCH 01/12] mm: add a new config to manage the code
References: <55704A7E.5030507@huawei.com>
In-Reply-To: <55704A7E.5030507@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, nao.horiguchi@gmail.com, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, "Luck, Tony" <tony.luck@intel.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

This patch introduces a new config called "CONFIG_ACPI_MIRROR_MEMORY", it is
used to on/off the feature.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/Kconfig | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/Kconfig b/mm/Kconfig
index 390214d..4f2a726 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -200,6 +200,14 @@ config MEMORY_HOTREMOVE
 	depends on MEMORY_HOTPLUG && ARCH_ENABLE_MEMORY_HOTREMOVE
 	depends on MIGRATION
 
+config MEMORY_MIRROR
+	bool "Address range mirroring support"
+	depends on X86 && NUMA
+	default y
+	help
+	  This feature depends on hardware and firmware support.
+	  ACPI or EFI records the mirror info.
+
 #
 # If we have space for more page flags then we can enable additional
 # optimizations and functionality.
-- 
2.0.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
