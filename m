Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id CD6EF8E0001
	for <linux-mm@kvack.org>; Thu, 20 Sep 2018 13:31:50 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id v186-v6so3407195pgb.14
        for <linux-mm@kvack.org>; Thu, 20 Sep 2018 10:31:50 -0700 (PDT)
Received: from EX13-EDG-OU-001.vmware.com (ex13-edg-ou-001.vmware.com. [208.91.0.189])
        by mx.google.com with ESMTPS id x29-v6si4687310pga.674.2018.09.20.10.31.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 20 Sep 2018 10:31:49 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
Subject: [PATCH v2 15/20] mm/balloon_compaction: suppress allocation warnings
Date: Thu, 20 Sep 2018 10:30:21 -0700
Message-ID: <20180920173026.141333-16-namit@vmware.com>
In-Reply-To: <20180920173026.141333-1-namit@vmware.com>
References: <20180920173026.141333-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Arnd Bergmann <arnd@arndb.de>
Cc: linux-kernel@vger.kernel.org, Xavier Deguillard <xdeguillard@vmware.com>, Nadav Amit <namit@vmware.com>, "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>, virtualization@lists.linux-foundation.org, linux-mm@kvack.org

There is no reason to print warnings when balloon page allocation fails.

Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
Cc: virtualization@lists.linux-foundation.org
Cc: linux-mm@kvack.org
Reviewed-by: Xavier Deguillard <xdeguillard@vmware.com>
Signed-off-by: Nadav Amit <namit@vmware.com>
---
 mm/balloon_compaction.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index ef858d547e2d..a6c0efb3544f 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -22,7 +22,8 @@
 struct page *balloon_page_alloc(void)
 {
 	struct page *page = alloc_page(balloon_mapping_gfp_mask() |
-				       __GFP_NOMEMALLOC | __GFP_NORETRY);
+				       __GFP_NOMEMALLOC | __GFP_NORETRY |
+				       __GFP_NOWARN);
 	return page;
 }
 EXPORT_SYMBOL_GPL(balloon_page_alloc);
-- 
2.17.1
