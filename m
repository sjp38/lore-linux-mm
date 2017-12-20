Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 87A7C6B0253
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 10:56:01 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id v25so16660518pfg.14
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 07:56:01 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id o3si13123435pld.65.2017.12.20.07.56.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Dec 2017 07:56:00 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v2 0/8] Restructure struct page
Date: Wed, 20 Dec 2017 07:55:44 -0800
Message-Id: <20171220155552.15884-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linuxfoundation.org, Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

This series does not attempt any grand restructuring as I proposed last
week.  Instead, it cures the worst of the indentitis, fixes the
documentation and reduces the ifdeffery.  The only layout change is
compound_dtor and compound_order are each reduced to one byte.

Changes v2:
 - Add acks
 - Improve changelogs (mostly at Michal's suggestion)
 - Improve documentation (patch 7) with Randy's suggestion and add
   a note about the treatment of _mapcount.

Matthew Wilcox (8):
  mm: Align struct page more aesthetically
  mm: De-indent struct page
  mm: Remove misleading alignment claims
  mm: Improve comment on page->mapping
  mm: Introduce _slub_counter_t
  mm: Store compound_dtor / compound_order as bytes
  mm: Document how to use struct page
  mm: Remove reference to PG_buddy

 include/linux/mm_types.h | 153 ++++++++++++++++++++++-------------------------
 1 file changed, 73 insertions(+), 80 deletions(-)

-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
