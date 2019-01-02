Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id EF6358E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 03:59:42 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id t22-v6so8802174lji.14
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 00:59:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w6-v6sor29536042lji.26.2019.01.02.00.59.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 00:59:40 -0800 (PST)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Subject: [RFC v3 1/3] vmalloc: export __vmalloc_node_range for CONFIG_TEST_VMALLOC_MODULE
Date: Wed,  2 Jan 2019 09:59:22 +0100
Message-Id: <20190102085924.14145-2-urezki@gmail.com>
In-Reply-To: <20190102085924.14145-1-urezki@gmail.com>
References: <20190102085924.14145-1-urezki@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Kees Cook <keescook@chromium.org>, Shuah Khan <shuah@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: LKML <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Thomas Gleixner <tglx@linutronix.de>, "Uladzislau Rezki (Sony)" <urezki@gmail.com>

Export __vmaloc_node_range() function if CONFIG_TEST_VMALLOC_MODULE is
enabled. Some test cases in vmalloc test suite module require and make
use of that function. Please note, that it is not supposed to be used
for other purposes.

We need it only for performance analysis, stressing and stability check
of vmalloc allocator.

Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
---
 mm/vmalloc.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index cfea25be7754..1f24aecd1d7e 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1764,6 +1764,15 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 	return NULL;
 }
 
+/*
+ * This is only for performance analysis of vmalloc and stress purpose.
+ * It is required by vmalloc test module, therefore do not use it other
+ * than that.
+ */
+#ifdef CONFIG_TEST_VMALLOC_MODULE
+EXPORT_SYMBOL_GPL(__vmalloc_node_range);
+#endif
+
 /**
  *	__vmalloc_node  -  allocate virtually contiguous memory
  *	@size:		allocation size
-- 
2.11.0
