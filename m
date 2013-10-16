Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 3AE116B0031
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 14:45:20 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id bj1so1492195pad.28
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 11:45:19 -0700 (PDT)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjennings@medulla.variantweb.net>;
	Wed, 16 Oct 2013 12:45:17 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 77A791FF0021
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 12:45:04 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r9GIjCW7290300
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 12:45:12 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r9GIjCA9032403
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 12:45:12 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH] MAINTAINERS: zswap/zbud: change maintainer email address
Date: Wed, 16 Oct 2013 13:43:49 -0500
Message-Id: <1381949029-7162-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Current email address will soon be non-operational.

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 MAINTAINERS | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 8a0cbf3..57d741d 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -9464,7 +9464,7 @@ F:	drivers/net/hamradio/*scc.c
 F:	drivers/net/hamradio/z8530.h
 
 ZBUD COMPRESSED PAGE ALLOCATOR
-M:	Seth Jennings <sjenning@linux.vnet.ibm.com>
+M:	Seth Jennings <sjennings@variantweb.net>
 L:	linux-mm@kvack.org
 S:	Maintained
 F:	mm/zbud.c
@@ -9493,7 +9493,7 @@ S:	Maintained
 F:	drivers/tty/serial/zs.*
 
 ZSWAP COMPRESSED SWAP CACHING
-M:	Seth Jennings <sjenning@linux.vnet.ibm.com>
+M:	Seth Jennings <sjennings@variantweb.net>
 L:	linux-mm@kvack.org
 S:	Maintained
 F:	mm/zswap.c
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
