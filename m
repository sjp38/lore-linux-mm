Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 953886B0262
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 18:49:40 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id fi2so165845404pad.3
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 15:49:40 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id d86si16422436pfe.90.2016.09.29.15.49.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Sep 2016 15:49:39 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v4 05/12] dax: make 'wait_table' global variable static
Date: Thu, 29 Sep 2016 16:49:23 -0600
Message-Id: <1475189370-31634-6-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1475189370-31634-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1475189370-31634-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

The global 'wait_table' variable is only used within fs/dax.c, and
generates the following sparse warning:

fs/dax.c:39:19: warning: symbol 'wait_table' was not declared. Should it be static?

Make it static so it has scope local to fs/dax.c, and to make sparse happy.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/dax.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/dax.c b/fs/dax.c
index 9b9be8a..ac28cdf 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -52,7 +52,7 @@
 #define DAX_WAIT_TABLE_BITS 12
 #define DAX_WAIT_TABLE_ENTRIES (1 << DAX_WAIT_TABLE_BITS)
 
-wait_queue_head_t wait_table[DAX_WAIT_TABLE_ENTRIES];
+static wait_queue_head_t wait_table[DAX_WAIT_TABLE_ENTRIES];
 
 static int __init init_dax_wait_table(void)
 {
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
