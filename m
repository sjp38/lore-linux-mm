Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9D0E56B0033
	for <linux-mm@kvack.org>; Fri, 29 Dec 2017 02:54:33 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 8so29727352pfv.12
        for <linux-mm@kvack.org>; Thu, 28 Dec 2017 23:54:33 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id q12si28032587plr.626.2017.12.28.23.54.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Dec 2017 23:54:29 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 02/17] mm: don't export arch_add_memory
Date: Fri, 29 Dec 2017 08:53:51 +0100
Message-Id: <20171229075406.1936-3-hch@lst.de>
In-Reply-To: <20171229075406.1936-1-hch@lst.de>
References: <20171229075406.1936-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, Michal Hocko <mhocko@kernel.org>, linux-nvdimm@lists.01.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Only x86_64 and sh export this symbol, and it is not used by any
modular code.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/sh/mm/init.c     | 1 -
 arch/x86/mm/init_64.c | 1 -
 2 files changed, 2 deletions(-)

diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index bf726af5f1a5..afc54d593a26 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -498,7 +498,6 @@ int arch_add_memory(int nid, u64 start, u64 size, bool want_memblock)
 
 	return ret;
 }
-EXPORT_SYMBOL_GPL(arch_add_memory);
 
 #ifdef CONFIG_NUMA
 int memory_add_physaddr_to_nid(u64 addr)
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 4a837289f2ad..8acdc35c2dfa 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -796,7 +796,6 @@ int arch_add_memory(int nid, u64 start, u64 size, bool want_memblock)
 
 	return add_pages(nid, start_pfn, nr_pages, want_memblock);
 }
-EXPORT_SYMBOL_GPL(arch_add_memory);
 
 #define PAGE_INUSE 0xFD
 
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
