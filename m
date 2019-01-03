Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 615E58E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 09:22:35 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id t7-v6so9602852ljg.9
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 06:22:35 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p8-v6sor31840405ljj.23.2019.01.03.06.22.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 Jan 2019 06:22:33 -0800 (PST)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Subject: [RFC PATCH 1/3] vmalloc: export __vmalloc_node_range for CONFIG_TEST_VMALLOC_MODULE
Date: Thu,  3 Jan 2019 15:21:06 +0100
Message-Id: <20190103142108.20744-2-urezki@gmail.com>
In-Reply-To: <20190103142108.20744-1-urezki@gmail.com>
References: <20190103142108.20744-1-urezki@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, Shuah Khan <shuah@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Thomas Gleixner <tglx@linutronix.de>, "Uladzislau Rezki (Sony)" <urezki@gmail.com>

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
index 97d4b25d0373..1c512fff8a56 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1768,6 +1768,15 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
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
