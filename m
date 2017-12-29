Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id BA7D06B0033
	for <linux-mm@kvack.org>; Thu, 28 Dec 2017 22:48:49 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id v2so10634328iog.10
        for <linux-mm@kvack.org>; Thu, 28 Dec 2017 19:48:49 -0800 (PST)
Received: from smtpbgau1.qq.com (smtpbgau1.qq.com. [54.206.16.166])
        by mx.google.com with ESMTPS id k4si18055757ita.143.2017.12.28.19.48.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 28 Dec 2017 19:48:48 -0800 (PST)
From: Huacai Chen <chenhc@lemote.com>
Subject: [PATCH] kallsyms: let print_ip_sym() print raw addresses
Date: Fri, 29 Dec 2017 11:49:42 +0800
Message-Id: <1514519382-405-1-git-send-email-chenhc@lemote.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Fuxin Zhang <zhangfx@lemote.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huacai Chen <chenhc@lemote.com>

print_ip_sym() is mostly used for debugging, so I think it should print
the raw addresses.

Signed-off-by: Huacai Chen <chenhc@lemote.com>
---
 include/linux/kallsyms.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/kallsyms.h b/include/linux/kallsyms.h
index bd118a6..e502db8 100644
--- a/include/linux/kallsyms.h
+++ b/include/linux/kallsyms.h
@@ -131,7 +131,7 @@ static inline void print_symbol(const char *fmt, unsigned long addr)
 
 static inline void print_ip_sym(unsigned long ip)
 {
-	printk("[<%p>] %pS\n", (void *) ip, (void *) ip);
+	printk("[<%px>] %pS\n", (void *) ip, (void *) ip);
 }
 
 #endif /*_LINUX_KALLSYMS_H*/
-- 
2.7.0



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
