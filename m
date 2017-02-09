Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id CA8F06B0387
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 08:16:25 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 204so4118347pge.5
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 05:16:25 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id w28si10030177pge.203.2017.02.09.05.16.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Feb 2017 05:16:25 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id v184so286519pgv.1
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 05:16:24 -0800 (PST)
Date: Thu, 9 Feb 2017 22:16:25 +0900
From: Jinbum Park <jinb.park7@gmail.com>
Subject: [PATCH] mm: testcases for RODATA: fix config dependency
Message-ID: <20170209131625.GA16954@pjb1027-Latitude-E5410>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: keescook@chromium.org, valentinrothberg@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Since DEBUG_RODATA has renamed to STRICT_KERNEL_RWX,
Fix the config dependency.

Reported-by: Valentin Rothberg <valentinrothberg@gmail.com>
Signed-off-by: Jinbum Park <jinb.park7@gmail.com>
---
 mm/Kconfig.debug | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index 3e5eada..3c88b7e 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -93,7 +93,7 @@ config DEBUG_PAGE_REF
 
 config DEBUG_RODATA_TEST
     bool "Testcase for the marking rodata read-only"
-    depends on DEBUG_RODATA
+    depends on STRICT_KERNEL_RWX
     ---help---
       This option enables a testcase for the setting rodata read-only.
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
