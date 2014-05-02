Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f43.google.com (mail-oa0-f43.google.com [209.85.219.43])
	by kanga.kvack.org (Postfix) with ESMTP id 0E7DC6B0036
	for <linux-mm@kvack.org>; Fri,  2 May 2014 14:54:45 -0400 (EDT)
Received: by mail-oa0-f43.google.com with SMTP id eb12so5661924oac.30
        for <linux-mm@kvack.org>; Fri, 02 May 2014 11:54:44 -0700 (PDT)
Received: from mail-ob0-x22d.google.com (mail-ob0-x22d.google.com [2607:f8b0:4003:c01::22d])
        by mx.google.com with ESMTPS id rk8si24721971oeb.93.2014.05.02.11.54.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 02 May 2014 11:54:44 -0700 (PDT)
Received: by mail-ob0-f173.google.com with SMTP id wm4so2407328obc.32
        for <linux-mm@kvack.org>; Fri, 02 May 2014 11:54:43 -0700 (PDT)
From: "Seth Jennings" <sjennings@variantweb.net>
Subject: [PATCH] MAINTAINERS: zswap/zbud: change maintainer email address
Date: Fri,  2 May 2014 13:54:41 -0500
Message-Id: <1399056881-18153-1-git-send-email-sjennings@variantweb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjennings@variantweb.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Fabian Frederick <fabf@skynet.be>

sjenning@linux.vnet.ibm.com is no longer a viable entity.

Resend from 2013-10-16.  Just noticed that it didn't get upstream.

Signed-off-by: Seth Jennings <sjennings@variantweb.net>
---
 MAINTAINERS | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 900d98e..b538cdf 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -9808,7 +9808,7 @@ F:	drivers/net/hamradio/*scc.c
 F:	drivers/net/hamradio/z8530.h
 
 ZBUD COMPRESSED PAGE ALLOCATOR
-M:	Seth Jennings <sjenning@linux.vnet.ibm.com>
+M:	Seth Jennings <sjennings@variantweb.net>
 L:	linux-mm@kvack.org
 S:	Maintained
 F:	mm/zbud.c
@@ -9853,7 +9853,7 @@ F:	mm/zsmalloc.c
 F:	include/linux/zsmalloc.h
 
 ZSWAP COMPRESSED SWAP CACHING
-M:	Seth Jennings <sjenning@linux.vnet.ibm.com>
+M:	Seth Jennings <sjennings@variantweb.net>
 L:	linux-mm@kvack.org
 S:	Maintained
 F:	mm/zswap.c
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
