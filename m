Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4CA788E0001
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 02:40:22 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id f13-v6so559824pgs.15
        for <linux-mm@kvack.org>; Mon, 17 Sep 2018 23:40:22 -0700 (PDT)
Received: from EX13-EDG-OU-002.vmware.com (ex13-edg-ou-002.vmware.com. [208.91.0.190])
        by mx.google.com with ESMTPS id f8-v6si17201045pgl.383.2018.09.17.23.40.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 17 Sep 2018 23:40:20 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
Subject: [PATCH 14/19] mm/balloon_compaction: suppress allocation warnings
Date: Mon, 17 Sep 2018 23:38:48 -0700
Message-ID: <20180918063853.198332-15-namit@vmware.com>
In-Reply-To: <20180918063853.198332-1-namit@vmware.com>
References: <20180918063853.198332-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, Nadav Amit <namit@vmware.com>, "Michael S.
 Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>, virtualization@lists.linux-foundation.org, linux-mm@kvack.org

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
