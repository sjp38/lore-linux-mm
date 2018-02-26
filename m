Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id E9D7C6B0005
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 18:09:31 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id m6so8258853plt.14
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 15:09:31 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j15sor1899147pgs.78.2018.02.26.15.09.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Feb 2018 15:09:30 -0800 (PST)
From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH] mm: Provide consistent declaration for num_poisoned_pages
Date: Mon, 26 Feb 2018 15:09:25 -0800
Message-Id: <1519686565-8224-1-git-send-email-linux@roeck-us.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, Matthias Kaehlcke <mka@chromium.org>

clang reports the following compile warning.

In file included from mm/vmscan.c:56:
./include/linux/swapops.h:327:22: warning:
	section attribute is specified on redeclared variable [-Wsection]
extern atomic_long_t num_poisoned_pages __read_mostly;
                     ^
./include/linux/mm.h:2585:22: note: previous declaration is here
extern atomic_long_t num_poisoned_pages;
                     ^

Let's use __read_mostly everywhere.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
Cc: Matthias Kaehlcke <mka@chromium.org>
---
 include/linux/mm.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ad06d42adb1a..bd4bd59f02c1 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2582,7 +2582,7 @@ extern int get_hwpoison_page(struct page *page);
 extern int sysctl_memory_failure_early_kill;
 extern int sysctl_memory_failure_recovery;
 extern void shake_page(struct page *p, int access);
-extern atomic_long_t num_poisoned_pages;
+extern atomic_long_t num_poisoned_pages __read_mostly;
 extern int soft_offline_page(struct page *page, int flags);
 
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
