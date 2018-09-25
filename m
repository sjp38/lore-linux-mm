Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4582E8E00A4
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 16:19:18 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id j15-v6so13108847pff.12
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 13:19:18 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id s21-v6si3300561pgm.651.2018.09.25.13.19.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Sep 2018 13:19:17 -0700 (PDT)
Subject: [PATCH v5 1/4] mm: Remove now defunct NO_BOOTMEM from depends list
 for deferred init
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Tue, 25 Sep 2018 13:19:15 -0700
Message-ID: <20180925201814.3576.15105.stgit@localhost.localdomain>
In-Reply-To: <20180925200551.3576.18755.stgit@localhost.localdomain>
References: <20180925200551.3576.18755.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org
Cc: pavel.tatashin@microsoft.com, mhocko@suse.com, dave.jiang@intel.com, dave.hansen@intel.com, jglisse@redhat.com, rppt@linux.vnet.ibm.com, dan.j.williams@intel.com, logang@deltatee.com, mingo@kernel.org, kirill.shutemov@linux.intel.com

The CONFIG_NO_BOOTMEM config option was recently removed by the patch "mm:
remove CONFIG_NO_BOOTMEM" (https://patchwork.kernel.org/patch/10600647/).
However it looks like it missed a few spots. The biggest one being the
dependency for deferred init. This patch goes through and removes the
remaining spots that appear to have been missed in the patch so that I am
able to build again with deferred memory initialization.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---

v5: New patch, added to fix regression found in latest linux-next

 arch/csky/Kconfig |    1 -
 mm/Kconfig        |    1 -
 2 files changed, 2 deletions(-)

diff --git a/arch/csky/Kconfig b/arch/csky/Kconfig
index fe2c94b94fe3..fb2a0ae84dd5 100644
--- a/arch/csky/Kconfig
+++ b/arch/csky/Kconfig
@@ -38,7 +38,6 @@ config CSKY
 	select HAVE_MEMBLOCK
 	select MAY_HAVE_SPARSE_IRQ
 	select MODULES_USE_ELF_RELA if MODULES
-	select NO_BOOTMEM
 	select OF
 	select OF_EARLY_FLATTREE
 	select OF_RESERVED_MEM
diff --git a/mm/Kconfig b/mm/Kconfig
index c6a0d82af45f..b4421aa608c4 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -631,7 +631,6 @@ config MAX_STACK_SIZE_MB
 config DEFERRED_STRUCT_PAGE_INIT
 	bool "Defer initialisation of struct pages to kthreads"
 	default n
-	depends on NO_BOOTMEM
 	depends on SPARSEMEM
 	depends on !NEED_PER_CPU_KM
 	depends on 64BIT
