Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id D3E526B0037
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 20:25:00 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id hz1so1932539pad.22
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 17:25:00 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id i3si614457pbe.229.2014.01.15.17.24.58
        for <linux-mm@kvack.org>;
        Wed, 15 Jan 2014 17:24:59 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v5 03/22] axonram: Fix bug in direct_access
Date: Wed, 15 Jan 2014 20:24:21 -0500
Message-Id: <75f939c2e1e5d481b7ca1598e4cbad78716f7f9a.1389779961.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1389779961.git.matthew.r.wilcox@intel.com>
References: <cover.1389779961.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1389779961.git.matthew.r.wilcox@intel.com>
References: <cover.1389779961.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>

The 'pfn' returned by axonram was completely bogus, and has been since
2008.

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 arch/powerpc/sysdev/axonram.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/powerpc/sysdev/axonram.c b/arch/powerpc/sysdev/axonram.c
index 1c16141..1fea249 100644
--- a/arch/powerpc/sysdev/axonram.c
+++ b/arch/powerpc/sysdev/axonram.c
@@ -155,7 +155,7 @@ axon_ram_direct_access(struct block_device *device, sector_t sector,
 	}
 
 	*kaddr = (void *)(bank->ph_addr + offset);
-	*pfn = virt_to_phys(kaddr) >> PAGE_SHIFT;
+	*pfn = virt_to_phys(*kaddr) >> PAGE_SHIFT;
 
 	return 0;
 }
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
