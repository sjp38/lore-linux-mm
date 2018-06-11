Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A6F886B028C
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 10:07:02 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j14-v6so10300132pfn.11
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 07:07:02 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o33-v6si65176771pld.170.2018.06.11.07.07.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Jun 2018 07:07:01 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v13 44/72] mm: Convert is_page_cache_freeable to XArray
Date: Mon, 11 Jun 2018 07:06:11 -0700
Message-Id: <20180611140639.17215-45-willy@infradead.org>
In-Reply-To: <20180611140639.17215-1-willy@infradead.org>
References: <20180611140639.17215-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

From: Matthew Wilcox <mawilcox@microsoft.com>

This is just a variable rename and comment change.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 mm/vmscan.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0448b1b366d9..575747728ee6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -572,12 +572,12 @@ static inline int is_page_cache_freeable(struct page *page)
 {
 	/*
 	 * A freeable page cache page is referenced only by the caller
-	 * that isolated the page, the page cache radix tree and
-	 * optional buffer heads at page->private.
+	 * that isolated the page, the page cache and optional buffer
+	 * heads at page->private.
 	 */
-	int radix_pins = PageTransHuge(page) && PageSwapCache(page) ?
+	int page_cache_pins = PageTransHuge(page) && PageSwapCache(page) ?
 		HPAGE_PMD_NR : 1;
-	return page_count(page) - page_has_private(page) == 1 + radix_pins;
+	return page_count(page) - page_has_private(page) == 1 + page_cache_pins;
 }
 
 static int may_write_to_inode(struct inode *inode, struct scan_control *sc)
-- 
2.17.1
