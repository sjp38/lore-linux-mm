Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B59D16B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 10:57:27 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id o19-v6so3598290pgn.14
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 07:57:27 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 33-v6si54395414plq.348.2018.06.07.07.57.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Jun 2018 07:57:26 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 3/6] Convert v4l2 event to struct_size
Date: Thu,  7 Jun 2018 07:57:17 -0700
Message-Id: <20180607145720.22590-4-willy@infradead.org>
In-Reply-To: <20180607145720.22590-1-willy@infradead.org>
References: <20180607145720.22590-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

From: Matthew Wilcox <mawilcox@microsoft.com>

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 drivers/media/v4l2-core/v4l2-event.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/media/v4l2-core/v4l2-event.c b/drivers/media/v4l2-core/v4l2-event.c
index 968c2eb08b5a..127fe6eb91d9 100644
--- a/drivers/media/v4l2-core/v4l2-event.c
+++ b/drivers/media/v4l2-core/v4l2-event.c
@@ -215,8 +215,7 @@ int v4l2_event_subscribe(struct v4l2_fh *fh,
 	if (elems < 1)
 		elems = 1;
 
-	sev = kvzalloc(sizeof(*sev) + sizeof(struct v4l2_kevent) * elems,
-		       GFP_KERNEL);
+	sev = kvzalloc(struct_size(sev, events, elems), GFP_KERNEL);
 	if (!sev)
 		return -ENOMEM;
 	for (i = 0; i < elems; i++)
-- 
2.17.0
