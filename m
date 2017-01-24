Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5C7346B0261
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 16:22:27 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id q3so169231929qtf.4
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 13:22:27 -0800 (PST)
Received: from mail-qt0-x242.google.com (mail-qt0-x242.google.com. [2607:f8b0:400d:c0d::242])
        by mx.google.com with ESMTPS id c43si14017976qte.145.2017.01.24.13.22.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 13:22:26 -0800 (PST)
Received: by mail-qt0-x242.google.com with SMTP id a29so28258354qtb.1
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 13:22:26 -0800 (PST)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCHv2] MAINTAINERS: add Dan Streetman to zswap maintainers
Date: Tue, 24 Jan 2017 16:22:00 -0500
Message-Id: <20170124212200.19052-1-ddstreet@ieee.org>
In-Reply-To: <20170124211724.18746-1-ddstreet@ieee.org>
References: <20170124211724.18746-1-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@redhat.com>
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

Add myself as zswap maintainer.

Cc: Seth Jennings <sjenning@redhat.com>
Signed-off-by: Dan Streetman <ddstreet@ieee.org>
---
You'd think I could get this simple patch right.  oops!

Since v1: fixed Seth's email in Cc: line

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
