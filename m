Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6472C6B0266
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 17:17:26 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id l7so172193329qtd.2
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 14:17:26 -0800 (PST)
Received: from mail-qt0-x244.google.com (mail-qt0-x244.google.com. [2607:f8b0:400d:c0d::244])
        by mx.google.com with ESMTPS id m90si14126791qtd.98.2017.01.24.14.17.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 14:17:25 -0800 (PST)
Received: by mail-qt0-x244.google.com with SMTP id l7so28632982qtd.3
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 14:17:25 -0800 (PST)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH] MAINTAINERS: add Dan Streetman to zbud maintainers
Date: Tue, 24 Jan 2017 17:17:05 -0500
Message-Id: <20170124221705.26523-1-ddstreet@ieee.org>
In-Reply-To: <CAC8qmcALc_wz3cM2N4VaVTDa+o9wFybfeV5r1tjf1N1pvZ0QMg@mail.gmail.com>
References: <CAC8qmcALc_wz3cM2N4VaVTDa+o9wFybfeV5r1tjf1N1pvZ0QMg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@redhat.com>
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Add myself as zbud maintainer.

Cc: Seth Jennings <sjenning@redhat.com>
Signed-off-by: Dan Streetman <ddstreet@ieee.org>
---
 MAINTAINERS | 1 +
 1 file changed, 1 insertion(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index e5575d5..0bd4b33 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -13681,6 +13681,7 @@ F:	drivers/net/hamradio/z8530.h
 
 ZBUD COMPRESSED PAGE ALLOCATOR
 M:	Seth Jennings <sjenning@redhat.com>
+M:	Dan Streetman <ddstreet@ieee.org>
 L:	linux-mm@kvack.org
 S:	Maintained
 F:	mm/zbud.c
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
