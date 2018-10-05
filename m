Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id AF9866B000A
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 12:16:50 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id f9-v6so12232486iok.23
        for <linux-mm@kvack.org>; Fri, 05 Oct 2018 09:16:50 -0700 (PDT)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id d128-v6si1953878ite.36.2018.10.05.09.16.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 05 Oct 2018 09:16:49 -0700 (PDT)
From: Logan Gunthorpe <logang@deltatee.com>
Date: Fri,  5 Oct 2018 10:16:41 -0600
Message-Id: <20181005161642.2462-5-logang@deltatee.com>
In-Reply-To: <20181005161642.2462-1-logang@deltatee.com>
References: <20181005161642.2462-1-logang@deltatee.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Subject: [PATCH 4/5] sh: mm: make use of new memblocks_present() helper
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-riscv@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org
Cc: Stephen Bates <sbates@raithlin.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <aou@eecs.berkeley.edu>, Christoph Hellwig <hch@lst.de>, Logan Gunthorpe <logang@deltatee.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Dan Williams <dan.j.williams@intel.com>, Rob Herring <robh@kernel.org>

Cleanup the open coded for_each_memblock() loop that is equivalent
to the new memblocks_present() helper.

Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Cc: Rich Felker <dalias@libc.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Rob Herring <robh@kernel.org>
---
 arch/sh/mm/init.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index 7713c084d040..f601f96408ee 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -235,12 +235,7 @@ static void __init do_init_bootmem(void)
 
 	plat_mem_setup();
 
-	for_each_memblock(memory, reg) {
-		int nid = memblock_get_region_node(reg);
-
-		memory_present(nid, memblock_region_memory_base_pfn(reg),
-			memblock_region_memory_end_pfn(reg));
-	}
+	memblocks_present();
 	sparse_init();
 }
 
-- 
2.19.0
