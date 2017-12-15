Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8E4A26B0253
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 09:10:13 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id y2so7031231pgv.8
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 06:10:13 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id x12si4619603pgq.307.2017.12.15.06.10.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 06:10:12 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 03/17] mm: don't export __add_pages
Date: Fri, 15 Dec 2017 15:09:33 +0100
Message-Id: <20171215140947.26075-4-hch@lst.de>
In-Reply-To: <20171215140947.26075-1-hch@lst.de>
References: <20171215140947.26075-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, linux-nvdimm@lists.01.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This function isn't used by any modules, and is only to be called
from core MM code.  This includes the calls for the add_pages wrapper
that might be inlined.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/memory_hotplug.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index c52aa05b106c..5c6f96e6b334 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -334,7 +334,6 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
 out:
 	return err;
 }
-EXPORT_SYMBOL_GPL(__add_pages);
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
 /* find the smallest valid pfn in the range [start_pfn, end_pfn) */
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
