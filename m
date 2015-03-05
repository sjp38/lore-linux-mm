Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 6F1166B0038
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 07:35:58 -0500 (EST)
Received: by pdbfl12 with SMTP id fl12so34856757pdb.5
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 04:35:58 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id gl1si9118455pbd.174.2015.03.05.04.35.57
        for <linux-mm@kvack.org>;
        Thu, 05 Mar 2015 04:35:57 -0800 (PST)
Date: Thu, 5 Mar 2015 20:35:34 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [PATCH mmotm] x86, mm: ioremap_pud_capable can be static
Message-ID: <20150305123534.GA21563@snb>
References: <201503052019.YDsQ378S%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201503052019.YDsQ378S%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org


Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 ioremap.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/ioremap.c b/lib/ioremap.c
index 3055ada..1634c53 100644
--- a/lib/ioremap.c
+++ b/lib/ioremap.c
@@ -14,9 +14,9 @@
 #include <asm/pgtable.h>
 
 #ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
-int __read_mostly ioremap_pud_capable;
-int __read_mostly ioremap_pmd_capable;
-int __read_mostly ioremap_huge_disabled;
+static int __read_mostly ioremap_pud_capable;
+static int __read_mostly ioremap_pmd_capable;
+static int __read_mostly ioremap_huge_disabled;
 
 static int __init set_nohugeiomap(char *str)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
