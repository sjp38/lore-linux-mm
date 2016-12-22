Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C89C26B034A
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 16:19:06 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f188so669126231pgc.1
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 13:19:06 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id b10si31949871pfd.39.2016.12.22.13.19.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Dec 2016 13:19:06 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v2 1/4] dax: kill uml support
Date: Thu, 22 Dec 2016 14:18:53 -0700
Message-Id: <1482441536-14550-2-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1482441536-14550-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1482441536-14550-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dan Williams <dan.j.williams@intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Dave Hansen <dave.hansen@intel.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-arch@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Ross Zwisler <ross.zwisler@linux.intel.com>

From: Dan Williams <dan.j.williams@intel.com>

The lack of common transparent-huge-page helpers for UML is becoming
increasingly painful for fs/dax.c now that it is growing more pmd
functionality. Add UML to the list of unsupported architectures.

Cc: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
[rez: squashed #ifdef removal into another patch in the series ]
Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index c2a377c..661931f 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -37,7 +37,7 @@ source "fs/f2fs/Kconfig"
 config FS_DAX
 	bool "Direct Access (DAX) support"
 	depends on MMU
-	depends on !(ARM || MIPS || SPARC)
+	depends on !(ARM || MIPS || SPARC || UML)
 	help
 	  Direct Access (DAX) can be used on memory-backed block devices.
 	  If the block device supports DAX and the filesystem supports DAX,
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
