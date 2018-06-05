Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 14A6D6B0007
	for <linux-mm@kvack.org>; Tue,  5 Jun 2018 04:16:34 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id c7-v6so1556784itd.7
        for <linux-mm@kvack.org>; Tue, 05 Jun 2018 01:16:34 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id k12-v6si40644578ioa.139.2018.06.05.01.16.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jun 2018 01:16:33 -0700 (PDT)
Date: Tue, 5 Jun 2018 11:16:16 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH] mm, memory_failure: remove a stray tab
Message-ID: <20180605081616.o2q4wdbvolggefck@kili.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Dan Williams <dan.j.williams@intel.com>
Cc: linux-mm@kvack.org, kernel-janitors@vger.kernel.org

The return statement is indented too far.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index de0bc897d6e7..72cde4b0939e 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1147,7 +1147,7 @@ static unsigned long dax_mapping_size(struct address_space *mapping,
 	if (page->mapping != mapping) {
 		xa_unlock_irq(&mapping->i_pages);
 		i_mmap_unlock_read(mapping);
-			return 0;
+		return 0;
 	}
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
