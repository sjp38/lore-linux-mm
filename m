Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id B50706B025E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 02:15:55 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id fg1so35307256pad.1
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 23:15:55 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id i65si56177582pfb.54.2016.06.01.23.15.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jun 2016 23:15:55 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id c84so6757328pfc.1
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 23:15:54 -0700 (PDT)
From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH 4/4] mm/zsmalloc: remove unused header cpumask.h
Date: Thu,  2 Jun 2016 14:15:36 +0800
Message-Id: <94e9f6fee719fcaa91ee5767a9ad64658c6f5237.1464847139.git.geliangtang@gmail.com>
In-Reply-To: <7cc1b41351a96e7d67fcf4bd2a6987b71793cb27.1464847139.git.geliangtang@gmail.com>
References: <7cc1b41351a96e7d67fcf4bd2a6987b71793cb27.1464847139.git.geliangtang@gmail.com>
In-Reply-To: <866efd744a89b6e16c9d3acd1a00b011adbd59af.1464847139.git.geliangtang@gmail.com>
References: <7cc1b41351a96e7d67fcf4bd2a6987b71793cb27.1464847139.git.geliangtang@gmail.com> <f0fa3738403f886988141182e8e4bac7efed05c7.1464847139.git.geliangtang@gmail.com> <866efd744a89b6e16c9d3acd1a00b011adbd59af.1464847139.git.geliangtang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Geliang Tang <geliangtang@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Remove unused header cpumask.h from mm/zsmalloc.c.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 mm/zsmalloc.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index b6d4f25..a93327e 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -57,7 +57,6 @@
 #include <linux/slab.h>
 #include <asm/tlbflush.h>
 #include <asm/pgtable.h>
-#include <linux/cpumask.h>
 #include <linux/cpu.h>
 #include <linux/vmalloc.h>
 #include <linux/preempt.h>
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
