Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 69DE46B0036
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 15:48:33 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id et14so176299pad.7
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 12:48:33 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id dk1si6664pbb.213.2014.07.22.12.48.32
        for <linux-mm@kvack.org>;
        Tue, 22 Jul 2014 12:48:32 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v8 03/22] axonram: Fix bug in direct_access
Date: Tue, 22 Jul 2014 15:47:51 -0400
Message-Id: <eee43fe81080cb2b6eba77f84e2b48ea6bc07573.1406058387.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1406058387.git.matthew.r.wilcox@intel.com>
References: <cover.1406058387.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1406058387.git.matthew.r.wilcox@intel.com>
References: <cover.1406058387.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, willy@linux.intel.com

The 'pfn' returned by axonram was completely bogus, and has been since
2008.

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 arch/powerpc/sysdev/axonram.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/powerpc/sysdev/axonram.c b/arch/powerpc/sysdev/axonram.c
index 47b6b9f..830edc8 100644
--- a/arch/powerpc/sysdev/axonram.c
+++ b/arch/powerpc/sysdev/axonram.c
@@ -156,7 +156,7 @@ axon_ram_direct_access(struct block_device *device, sector_t sector,
 	}
 
 	*kaddr = (void *)(bank->ph_addr + offset);
-	*pfn = virt_to_phys(kaddr) >> PAGE_SHIFT;
+	*pfn = virt_to_phys(*kaddr) >> PAGE_SHIFT;
 
 	return 0;
 }
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
