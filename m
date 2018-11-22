Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 28D056B2D68
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 16:32:35 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id f9so3161145pgs.13
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 13:32:35 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n2si53637538pgr.67.2018.11.22.13.32.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 22 Nov 2018 13:32:33 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 0/2] Better support for THP in page cache
Date: Thu, 22 Nov 2018 13:32:22 -0800
Message-Id: <20181122213224.12793-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>

This is the first step towards representing THPs more efficiently in
the page cache.  The next step is to insert one head page instead of
HPAGE_PMD_NR.  This passes a Trinity run, but I'm sure there's a
better test-case out there for THP.

Matthew Wilcox (2):
  mm: Remove redundant test from find_get_pages_contig
  page cache: Store only head pages in i_pages

 include/linux/pagemap.h |   9 ++++
 mm/filemap.c            | 106 +++++++++++-----------------------------
 mm/khugepaged.c         |   4 +-
 mm/shmem.c              |   2 +-
 mm/swap_state.c         |   2 +-
 5 files changed, 42 insertions(+), 81 deletions(-)

-- 
2.19.1
