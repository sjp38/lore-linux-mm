Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6B6416B025E
	for <linux-mm@kvack.org>; Sat, 23 Dec 2017 07:59:49 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id m39so13645312plg.19
        for <linux-mm@kvack.org>; Sat, 23 Dec 2017 04:59:49 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id g3si18371817plb.153.2017.12.23.04.59.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 23 Dec 2017 04:59:48 -0800 (PST)
Date: Sat, 23 Dec 2017 20:59:43 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [RFC PATCH mmotm] kasan: __asan_set_shadow_00 can be static
Message-ID: <20171223125943.GA74341@lkp-ib03>
References: <201712232039.vNkPEjbE%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201712232039.vNkPEjbE%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Greg Hackmann <ghackmann@google.com>, Paul Lawrence <paullawrence@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


Fixes: 1749be8333b7 ("kasan: add functions for unpoisoning stack variables")
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 kasan.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 8aaee42..dcfcb26 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -778,12 +778,12 @@ EXPORT_SYMBOL(__asan_allocas_unpoison);
 	}								\
 	EXPORT_SYMBOL(__asan_set_shadow_##byte)
 
-DEFINE_ASAN_SET_SHADOW(00);
-DEFINE_ASAN_SET_SHADOW(f1);
-DEFINE_ASAN_SET_SHADOW(f2);
-DEFINE_ASAN_SET_SHADOW(f3);
-DEFINE_ASAN_SET_SHADOW(f5);
-DEFINE_ASAN_SET_SHADOW(f8);
+static DEFINE_ASAN_SET_SHADOW(00);
+static DEFINE_ASAN_SET_SHADOW(f1);
+static DEFINE_ASAN_SET_SHADOW(f2);
+static DEFINE_ASAN_SET_SHADOW(f3);
+static DEFINE_ASAN_SET_SHADOW(f5);
+static DEFINE_ASAN_SET_SHADOW(f8);
 
 #ifdef CONFIG_MEMORY_HOTPLUG
 static int __meminit kasan_mem_notifier(struct notifier_block *nb,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
