Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 687896B006E
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 20:58:33 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id rd3so103605187pab.3
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 17:58:33 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id q2si193960pdr.190.2015.02.03.17.58.32
        for <linux-mm@kvack.org>;
        Tue, 03 Feb 2015 17:58:32 -0800 (PST)
Date: Wed, 4 Feb 2015 09:58:22 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [ras:rfc-mirror 2/2] mm/memblock.c:57:6: sparse: symbol
 'memblock_have_mirror' was not declared. Should it be static?
Message-ID: <201502040909.te1Zvay3%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Catalin Marinas <catalin.marinas@arm.com>, Fabian Frederick <fabf@skynet.be>, Philipp Hachtmann <phacht@linux.vnet.ibm.com>, Emil Medve <Emilian.Medve@freescale.com>, Laura Abbott <lauraa@codeaurora.org>, Akinobu Mita <akinobu.mita@gmail.com>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/ras/ras.git rfc-mirror
head:   db3eb444d5eb1bbfe26891229eff520f523f2c47
commit: db3eb444d5eb1bbfe26891229eff520f523f2c47 [2/2] mirror: allocate boot time data structures from mirrored memory
reproduce:
  # apt-get install sparse
  git checkout db3eb444d5eb1bbfe26891229eff520f523f2c47
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> mm/memblock.c:57:6: sparse: symbol 'memblock_have_mirror' was not declared. Should it be static?

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
