Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 58FAC681010
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 14:32:55 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 204so34838513pfx.1
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 11:32:55 -0800 (PST)
Received: from mail-pf0-x234.google.com (mail-pf0-x234.google.com. [2607:f8b0:400e:c00::234])
        by mx.google.com with ESMTPS id r80si7856361pfa.30.2017.02.16.11.32.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Feb 2017 11:32:54 -0800 (PST)
Received: by mail-pf0-x234.google.com with SMTP id 189so7607651pfu.3
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 11:32:54 -0800 (PST)
From: Stephen Boyd <stephen.boyd@linaro.org>
Subject: [PATCH] mm/maccess.c: Fix up kernel doc notation
Date: Thu, 16 Feb 2017 11:32:51 -0800
Message-Id: <20170216193251.20242-1-stephen.boyd@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org

One argument was incorrect, two functions weren't showing the
brief description, and the docs for strncpy_from_unsafe() had a
colon attached to it. Fix it up.

Cc: <linux-doc@vger.kernel.org>
Signed-off-by: Stephen Boyd <stephen.boyd@linaro.org>
---
 mm/maccess.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/maccess.c b/mm/maccess.c
index 78f9274dd49d..ee305aa22535 100644
--- a/mm/maccess.c
+++ b/mm/maccess.c
@@ -6,7 +6,7 @@
 #include <linux/uaccess.h>
 
 /**
- * probe_kernel_read(): safely attempt to read from a location
+ * probe_kernel_read() - safely attempt to read from a location.
  * @dst: pointer to the buffer that shall take the data
  * @src: address to read from
  * @size: size of the data chunk
@@ -40,7 +40,7 @@ long __probe_kernel_read(void *dst, const void *src, size_t size)
 EXPORT_SYMBOL_GPL(probe_kernel_read);
 
 /**
- * probe_kernel_write(): safely attempt to write to a location
+ * probe_kernel_write() - safely attempt to write to a location.
  * @dst: address to write to
  * @src: pointer to the data that shall be written
  * @size: size of the data chunk
@@ -67,10 +67,10 @@ long __probe_kernel_write(void *dst, const void *src, size_t size)
 EXPORT_SYMBOL_GPL(probe_kernel_write);
 
 /**
- * strncpy_from_unsafe: - Copy a NUL terminated string from unsafe address.
+ * strncpy_from_unsafe() - Copy a NUL terminated string from unsafe address.
  * @dst:   Destination address, in kernel space.  This buffer must be at
  *         least @count bytes long.
- * @src:   Unsafe address.
+ * @unsafe_addr:   Unsafe address.
  * @count: Maximum number of bytes to copy, including the trailing NUL.
  *
  * Copies a NUL-terminated string from unsafe address to kernel buffer.
-- 
2.10.0.297.gf6727b0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
