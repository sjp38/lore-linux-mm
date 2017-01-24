Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5AC9B6B0038
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 16:17:51 -0500 (EST)
Received: by mail-yb0-f197.google.com with SMTP id f67so226318814ybc.4
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 13:17:51 -0800 (PST)
Received: from mail-yw0-x243.google.com (mail-yw0-x243.google.com. [2607:f8b0:4002:c05::243])
        by mx.google.com with ESMTPS id a3si5495895ybg.315.2017.01.24.13.17.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 13:17:50 -0800 (PST)
Received: by mail-yw0-x243.google.com with SMTP id q71so17048074ywg.3
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 13:17:50 -0800 (PST)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH] MAINTAINERS: add Dan Streetman to zswap maintainers
Date: Tue, 24 Jan 2017 16:17:24 -0500
Message-Id: <20170124211724.18746-1-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@redhat.com>
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Seth Jennings <sjennings@redhat.com>

Add myself as zswap maintainer.

Cc: Seth Jennings <sjennings@redhat.com>
Signed-off-by: Dan Streetman <ddstreet@ieee.org>
---
Seth, I'd meant to send this last year, I assume you're still ok
adding me.  Did you want to stay on as maintainer also?

 MAINTAINERS | 1 +
 1 file changed, 1 insertion(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 741f35f..e5575d5 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -13736,6 +13736,7 @@ F:	Documentation/vm/zsmalloc.txt
 
 ZSWAP COMPRESSED SWAP CACHING
 M:	Seth Jennings <sjenning@redhat.com>
+M:	Dan Streetman <ddstreet@ieee.org>
 L:	linux-mm@kvack.org
 S:	Maintained
 F:	mm/zswap.c
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
