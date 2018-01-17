Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8711C280272
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 22:47:36 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id p89so13190600pfk.5
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 19:47:36 -0800 (PST)
Received: from heian.cn.fujitsu.com (mail.cn.fujitsu.com. [183.91.158.132])
        by mx.google.com with ESMTP id m4si2870696pgc.800.2018.01.16.19.47.34
        for <linux-mm@kvack.org>;
        Tue, 16 Jan 2018 19:47:35 -0800 (PST)
From: Dou Liyang <douly.fnst@cn.fujitsu.com>
Subject: [PATCH] mm/kmemleak: Make kmemleak_boot_config __init
Date: Wed, 17 Jan 2018 11:47:20 +0800
Message-ID: <20180117034720.26897-1-douly.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dou Liyang <douly.fnst@cn.fujitsu.com>, Catalin Marinas <catalin.marinas@arm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

The early_param() is only called during kernel initialization, So Linux
marks the functions of it with __init macro to save memory.

But it forgot to mark the kmemleak_boot_config(). So, Make it __init as
well.

Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Signed-off-by: Dou Liyang <douly.fnst@cn.fujitsu.com>
---
 mm/kmemleak.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index f656ca27f6c2..6ccd0c954189 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1962,7 +1962,7 @@ static void kmemleak_disable(void)
 /*
  * Allow boot-time kmemleak disabling (enabled by default).
  */
-static int kmemleak_boot_config(char *str)
+static int __init kmemleak_boot_config(char *str)
 {
 	if (!str)
 		return -EINVAL;
-- 
2.14.3



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
