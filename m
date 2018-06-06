Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9C2916B0003
	for <linux-mm@kvack.org>; Wed,  6 Jun 2018 15:41:48 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id x203-v6so3431377wmg.8
        for <linux-mm@kvack.org>; Wed, 06 Jun 2018 12:41:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n196-v6sor1596618wmd.62.2018.06.06.12.41.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Jun 2018 12:41:47 -0700 (PDT)
From: Mathieu Malaterre <malat@debian.org>
Subject: [PATCH] mm/memblock: add missing include <linux/bootmem.h>
Date: Wed,  6 Jun 2018 21:41:43 +0200
Message-Id: <20180606194144.16990-1-malat@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mathieu Malaterre <malat@debian.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Commit 26f09e9b3a06 ("mm/memblock: add memblock memory allocation apis")
introduced two new function definitions:
  a??memblock_virt_alloc_try_nid_nopanica??
and
  a??memblock_virt_alloc_try_nida??.
Commit ea1f5f3712af ("mm: define memblock_virt_alloc_try_nid_raw")
introduced the following function definition:
  a??memblock_virt_alloc_try_nid_rawa??

This commit adds an includeof header file <linux/bootmem.h> to provide the
missing function prototypes. Silence the following gcc warning (W=1):

  mm/memblock.c:1334:15: warning: no previous prototype for a??memblock_virt_alloc_try_nid_rawa?? [-Wmissing-prototypes]
  mm/memblock.c:1371:15: warning: no previous prototype for a??memblock_virt_alloc_try_nid_nopanica?? [-Wmissing-prototypes]
  mm/memblock.c:1407:15: warning: no previous prototype for a??memblock_virt_alloc_try_nida?? [-Wmissing-prototypes]

Signed-off-by: Mathieu Malaterre <malat@debian.org>
---
 mm/memblock.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/memblock.c b/mm/memblock.c
index feb9185d391e..c5fb9c846890 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -20,6 +20,7 @@
 #include <linux/kmemleak.h>
 #include <linux/seq_file.h>
 #include <linux/memblock.h>
+#include <linux/bootmem.h>
 
 #include <asm/sections.h>
 #include <linux/io.h>
-- 
2.11.0
