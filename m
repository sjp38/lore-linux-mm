Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 2D4136B006C
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 07:35:59 -0500 (EST)
Received: by pdbfl12 with SMTP id fl12so34856833pdb.5
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 04:35:58 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id gl1si9118455pbd.174.2015.03.05.04.35.57
        for <linux-mm@kvack.org>;
        Thu, 05 Mar 2015 04:35:58 -0800 (PST)
Date: Thu, 5 Mar 2015 20:35:34 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 126/298] lib/ioremap.c:17:19: sparse: symbol
 'ioremap_pud_capable' was not declared. Should it be static?
Message-ID: <201503052019.YDsQ378S%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   fe8eec967fb5db169b876720a6e0cced026173b6
commit: e4dc2631d6de08fe1ee5421944a71c7c89ed1d90 [126/298] x86, mm: support huge KVA mappings on x86
reproduce:
  # apt-get install sparse
  git checkout e4dc2631d6de08fe1ee5421944a71c7c89ed1d90
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> lib/ioremap.c:17:19: sparse: symbol 'ioremap_pud_capable' was not declared. Should it be static?
>> lib/ioremap.c:18:19: sparse: symbol 'ioremap_pmd_capable' was not declared. Should it be static?
>> lib/ioremap.c:19:19: sparse: symbol 'ioremap_huge_disabled' was not declared. Should it be static?

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
