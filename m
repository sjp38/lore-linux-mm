Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 574F96B0253
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 18:12:45 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id o124so280854894pfg.1
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 15:12:45 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id hm6si5740071pac.254.2016.08.23.15.04.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Aug 2016 15:04:33 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v2 5/9] dax: make 'wait_table' global variable static
Date: Tue, 23 Aug 2016 16:04:15 -0600
Message-Id: <20160823220419.11717-6-ross.zwisler@linux.intel.com>
In-Reply-To: <20160823220419.11717-1-ross.zwisler@linux.intel.com>
References: <20160823220419.11717-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Matthew Wilcox <mawilcox@microsoft.com>

The global 'wait_table' variable is only used within fs/dax.c, and
generates the following sparse warning:

fs/dax.c:39:19: warning: symbol 'wait_table' was not declared. Should it be static?

Make it static so it has scope local to fs/dax.c, and to make sparse happy.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/dax.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/dax.c b/fs/dax.c
index 8030f93..3066a9b 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -50,7 +50,7 @@
 #define DAX_WAIT_TABLE_BITS 12
 #define DAX_WAIT_TABLE_ENTRIES (1 << DAX_WAIT_TABLE_BITS)
 
-wait_queue_head_t wait_table[DAX_WAIT_TABLE_ENTRIES];
+static wait_queue_head_t wait_table[DAX_WAIT_TABLE_ENTRIES];
 
 static int __init init_dax_wait_table(void)
 {
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
