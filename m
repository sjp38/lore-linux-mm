Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id C41746B6CFB
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 00:14:29 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id d11so12376345wrq.18
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 21:14:29 -0800 (PST)
Received: from delany.relativists.org (delany.relativists.org. [176.31.98.17])
        by mx.google.com with ESMTPS id v206si7692256wmb.108.2018.12.03.21.14.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Dec 2018 21:14:27 -0800 (PST)
From: =?UTF-8?q?Adeodato=20Sim=C3=B3?= <dato@net.com.org.es>
Subject: [PATCH 1/3] mm: add include files so that function definitions have a prototype
Date: Tue,  4 Dec 2018 02:14:22 -0300
Message-Id: <466ad4ebe5d788e7be6a14fbbcaaa9596bac7141.1543899764.git.dato@net.com.org.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: kernel-janitors@vger.kernel.org

Previously, rodata_test(), usercopy_warn(), and usercopy_abort() were
defined without a matching prototype. Detected by -Wmissing-prototypes
GCC flag.

Signed-off-by: Adeodato Simó <dato@net.com.org.es>
---
I started poking at this after kernel-janitors got the suggestion[1]
to look into the -Wmissing-prototypes warnings.

Thanks for considering!

[1]: https://www.spinics.net/lists/linux-kernel-janitors/msg43981.html

 mm/rodata_test.c | 1 +
 mm/usercopy.c    | 1 +
 2 files changed, 2 insertions(+)

diff --git a/mm/rodata_test.c b/mm/rodata_test.c
index d908c8769b48..01306defbd1b 100644
--- a/mm/rodata_test.c
+++ b/mm/rodata_test.c
@@ -11,6 +11,7 @@
  */
 #define pr_fmt(fmt) "rodata_test: " fmt
 
+#include <linux/rodata_test.h>
 #include <linux/uaccess.h>
 #include <asm/sections.h>
 
diff --git a/mm/usercopy.c b/mm/usercopy.c
index 852eb4e53f06..f487ba4888df 100644
--- a/mm/usercopy.c
+++ b/mm/usercopy.c
@@ -20,6 +20,7 @@
 #include <linux/sched/task.h>
 #include <linux/sched/task_stack.h>
 #include <linux/thread_info.h>
+#include <linux/uaccess.h>
 #include <linux/atomic.h>
 #include <linux/jump_label.h>
 #include <asm/sections.h>
-- 
2.19.2
