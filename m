Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 36BF76B006C
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 22:38:43 -0400 (EDT)
Received: by pactm7 with SMTP id tm7so76896188pac.2
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 19:38:42 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id f10si4671450pdp.225.2015.06.26.19.38.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 26 Jun 2015 19:38:42 -0700 (PDT)
Message-ID: <558E0913.7020501@huawei.com>
Date: Sat, 27 Jun 2015 10:23:15 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC v2 PATCH 1/8] mm: add a new config to manage the code
References: <558E084A.60900@huawei.com>
In-Reply-To: <558E084A.60900@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, "Luck, Tony" <tony.luck@intel.com>, Hanjun Guo <guohanjun@huawei.com>, Xiexiuqi <xiexiuqi@huawei.com>, leon@leon.nu, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave.hansen@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

This patch introduces a new config called "CONFIG_ACPI_MIRROR_MEMORY", set it
off by default.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/Kconfig | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/Kconfig b/mm/Kconfig
index 390214d..c40bb8b 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -200,6 +200,14 @@ config MEMORY_HOTREMOVE
 	depends on MEMORY_HOTPLUG && ARCH_ENABLE_MEMORY_HOTREMOVE
 	depends on MIGRATION
 
+config MEMORY_MIRROR
+	bool "Address range mirroring support"
+	depends on X86 && MEMORY_FAILURE
+	default n
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
