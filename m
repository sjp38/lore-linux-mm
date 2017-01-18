Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7B3776B0260
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 21:10:55 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id v96so2733195ioi.5
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 18:10:55 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id k8si12774117itf.85.2017.01.17.18.10.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 18:10:54 -0800 (PST)
Subject: [PATCH] mm: fix <linux/pagemap.h> stray kernel-doc notation
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <b037e9a3-516c-ec02-6c8e-fa5479747ba6@infradead.org>
Date: Tue, 17 Jan 2017 18:10:51 -0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>

From: Randy Dunlap <rdunlap@infradead.org>

Delete stray (second) function description in find_lock_page()
kernel-doc notation.

Fixes: 2457aec63745e ("mm: non-atomically mark page accessed during page cache allocation where possible")

Note: scripts/kernel-doc just ignores the second function description.

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>
---
 include/linux/pagemap.h |    1 -
 1 file changed, 1 deletion(-)

--- lnx-410-rc4.orig/include/linux/pagemap.h
+++ lnx-410-rc4/include/linux/pagemap.h
@@ -266,7 +266,6 @@ static inline struct page *find_get_page
 
 /**
  * find_lock_page - locate, pin and lock a pagecache page
- * pagecache_get_page - find and get a page reference
  * @mapping: the address_space to search
  * @offset: the page index
  *

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
