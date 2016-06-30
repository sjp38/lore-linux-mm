Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6E2B86B025E
	for <linux-mm@kvack.org>; Thu, 30 Jun 2016 09:46:03 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f126so78589165wma.3
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 06:46:03 -0700 (PDT)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id hb4si4123820wjb.18.2016.06.30.06.46.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jun 2016 06:46:02 -0700 (PDT)
Received: by mail-wm0-x22e.google.com with SMTP id a66so119498513wme.0
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 06:46:02 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH] kasan: add newline to messages
Date: Thu, 30 Jun 2016 15:45:57 +0200
Message-Id: <1467294357-98002-1-git-send-email-dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, ryabinin.a.a@gmail.com, glider@google.com, kasan-dev@googlegroups.com, linux-mm@kvack.org
Cc: Dmitry Vyukov <dvyukov@google.com>

Currently GPF messages with KASAN look as follows:
kasan: GPF could be caused by NULL-ptr deref or user memory accessgeneral protection fault: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN
Add newlines.

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
---
 arch/x86/mm/kasan_init_64.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 1b1110f..0493c17 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -54,8 +54,8 @@ static int kasan_die_handler(struct notifier_block *self,
 			     void *data)
 {
 	if (val == DIE_GPF) {
-		pr_emerg("CONFIG_KASAN_INLINE enabled");
-		pr_emerg("GPF could be caused by NULL-ptr deref or user memory access");
+		pr_emerg("CONFIG_KASAN_INLINE enabled\n");
+		pr_emerg("GPF could be caused by NULL-ptr deref or user memory access\n");
 	}
 	return NOTIFY_OK;
 }
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
