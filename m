Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id 7207C900015
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 12:56:20 -0400 (EDT)
Received: by oihb142 with SMTP id b142so130335447oih.3
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 09:56:20 -0700 (PDT)
Received: from mail-ob0-x22d.google.com (mail-ob0-x22d.google.com. [2607:f8b0:4003:c01::22d])
        by mx.google.com with ESMTPS id c2si11254553oih.6.2015.06.02.09.56.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jun 2015 09:56:20 -0700 (PDT)
Received: by obew15 with SMTP id w15so133078989obe.1
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 09:56:19 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH] MAINTAINERS: add zpool
Date: Tue,  2 Jun 2015 12:56:06 -0400
Message-Id: <1433264166-31452-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Streetman <ddstreet@ieee.org>

Add entry for zpool to MAINTAINERS file.

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
---
 MAINTAINERS | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index e308718..5c0f13b 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -11056,6 +11056,13 @@ L:	zd1211-devs@lists.sourceforge.net (subscribers-only)
 S:	Maintained
 F:	drivers/net/wireless/zd1211rw/
 
+ZPOOL COMPRESSED PAGE STORAGE API
+M:	Dan Streetman <ddstreet@ieee.org>
+L:	linux-mm@kvack.org
+S:	Maintained
+F:	mm/zpool.c
+F:	include/linux/zpool.h
+
 ZR36067 VIDEO FOR LINUX DRIVER
 L:	mjpeg-users@lists.sourceforge.net
 L:	linux-media@vger.kernel.org
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
