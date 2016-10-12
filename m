Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 82C28280258
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 18:50:44 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id i85so55713957pfa.5
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 15:50:44 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id m6si9442179pab.331.2016.10.12.15.50.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Oct 2016 15:50:43 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v6 17/17] dax: remove "depends on BROKEN" from FS_DAX_PMD
Date: Wed, 12 Oct 2016 16:50:22 -0600
Message-Id: <20161012225022.15507-18-ross.zwisler@linux.intel.com>
In-Reply-To: <20161012225022.15507-1-ross.zwisler@linux.intel.com>
References: <20161012225022.15507-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

Now that DAX PMD faults are once again working and are now participating in
DAX's radix tree locking scheme, allow their config option to be enabled.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/Kconfig | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index 2bc7ad7..b6f0fce 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -55,7 +55,6 @@ config FS_DAX_PMD
 	depends on FS_DAX
 	depends on ZONE_DEVICE
 	depends on TRANSPARENT_HUGEPAGE
-	depends on BROKEN
 
 endif # BLOCK
 
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
