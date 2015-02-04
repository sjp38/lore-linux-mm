Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id B82556B0038
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 20:58:32 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id fa1so103794473pad.8
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 17:58:32 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id q2si193960pdr.190.2015.02.03.17.58.31
        for <linux-mm@kvack.org>;
        Tue, 03 Feb 2015 17:58:32 -0800 (PST)
Date: Wed, 4 Feb 2015 09:58:22 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [PATCH ras] mirror: memblock_have_mirror can be static
Message-ID: <20150204015822.GA10853@snb>
References: <201502040909.te1Zvay3%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201502040909.te1Zvay3%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Catalin Marinas <catalin.marinas@arm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Philipp Hachtmann <phacht@linux.vnet.ibm.com>, Fabian Frederick <fabf@skynet.be>, Xishi Qiu <qiuxishi@huawei.com>, Akinobu Mita <akinobu.mita@gmail.com>, Emil Medve <Emilian.Medve@freescale.com>

mm/memblock.c:57:6: sparse: symbol 'memblock_have_mirror' was not declared. Should it be static?

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 memblock.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 911ce52..8ea1dfc 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -54,7 +54,7 @@ int memblock_debug __initdata_memblock;
 #ifdef CONFIG_MOVABLE_NODE
 bool movable_node_enabled __initdata_memblock = false;
 #endif
-bool memblock_have_mirror __initdata_memblock = false;
+static bool memblock_have_mirror __initdata_memblock = false;
 static int memblock_can_resize __initdata_memblock;
 static int memblock_memory_in_slab __initdata_memblock = 0;
 static int memblock_reserved_in_slab __initdata_memblock = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
