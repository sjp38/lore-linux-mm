Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id C786C6B025F
	for <linux-mm@kvack.org>; Mon, 23 May 2016 13:21:47 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id hs7so1420865pac.1
        for <linux-mm@kvack.org>; Mon, 23 May 2016 10:21:47 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id fe3si53094553pad.175.2016.05.23.10.21.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 May 2016 10:21:46 -0700 (PDT)
Received: by mail-pa0-x233.google.com with SMTP id xk12so64261494pac.0
        for <linux-mm@kvack.org>; Mon, 23 May 2016 10:21:46 -0700 (PDT)
From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH] mm: make CONFIG_DEFERRED_STRUCT_PAGE_INIT depends on !FLATMEM explicitly
Date: Mon, 23 May 2016 09:54:31 -0700
Message-Id: <1464022471-30545-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, yang.shi@linaro.org

Per the suggestion from Michal Hocko [1], CONFIG_DEFERRED_STRUCT_PAGE_INIT
should be incompatible with FLATMEM, make this explicitly in Kconfig.

[1] http://lkml.kernel.org/r/20160523073157.GD2278@dhcp22.suse.cz

Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
 mm/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/Kconfig b/mm/Kconfig
index 2664c11..22fa818 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -649,6 +649,7 @@ config DEFERRED_STRUCT_PAGE_INIT
 	default n
 	depends on ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT
 	depends on MEMORY_HOTPLUG
+	depends on !FLATMEM
 	help
 	  Ordinarily all struct pages are initialised during early boot in a
 	  single thread. On very large machines this can take a considerable
-- 
2.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
