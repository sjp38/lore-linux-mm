Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0218F6B025E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 04:26:42 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a7so70774436pfj.3
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 01:26:41 -0700 (PDT)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id n8si8420589plk.532.2017.10.10.01.26.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Oct 2017 01:26:40 -0700 (PDT)
Received: from epcas5p3.samsung.com (unknown [182.195.41.41])
	by mailout1.samsung.com (KnoxPortal) with ESMTP id 20171010082637epoutp0156607700617953969144ce3ac064b078~sKAnVXKEK0327703277epoutp01a
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 08:26:37 +0000 (GMT)
From: Ayush Mittal <ayush.m@samsung.com>
Subject: [PATCH 1/1] mm: reducing page_owner structure size
Date: Tue, 10 Oct 2017 13:55:17 +0530
Message-Id: <1507623917-37991-1-git-send-email-ayush.m@samsung.com>
Content-Type: text/plain; charset="utf-8"
References: <CGME20171010082637epcas5p4b5d588057b336b4056b7bd2f84d52b32@epcas5p4.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vbabka@suse.cz, vinmenon@codeaurora.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: a.sahrawat@samsung.com, pankaj.m@samsung.com, v.narang@samsung.com, Ayush Mittal <ayush.m@samsung.com>

Maximum page order can be at max 10 which can be accomodated
in short data type(2 bytes).
last_migrate_reason is defined as enum type whose values can
be accomodated in short data type (2 bytes).

Total structure size is currently 16 bytes but after changing structure
size it goes to 12 bytes.

Signed-off-by: Ayush Mittal <ayush.m@samsung.com>
---
 mm/page_owner.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page_owner.c b/mm/page_owner.c
index 0fd9dcf..4ab438a 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -19,9 +19,9 @@
 #define PAGE_OWNER_STACK_DEPTH (16)
 
 struct page_owner {
-	unsigned int order;
+	unsigned short order;
+	short last_migrate_reason;
 	gfp_t gfp_mask;
-	int last_migrate_reason;
 	depot_stack_handle_t handle;
 };
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
