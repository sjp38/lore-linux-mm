Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2FECE6B052E
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 12:39:05 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id q22-v6so20545444iog.9
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 09:39:05 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id q18-v6si1126144ith.124.2018.11.07.09.39.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Nov 2018 09:39:02 -0800 (PST)
From: Logan Gunthorpe <logang@deltatee.com>
Date: Wed,  7 Nov 2018 10:38:57 -0700
Message-Id: <20181107173859.24096-1-logang@deltatee.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Subject: [PATCH 0/2] Introduce common code for risc-v sparsemem support
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-riscv@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Stephen Bates <sbates@raithlin.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <aou@eecs.berkeley.edu>, Christoph Hellwig <hch@lst.de>, Arnd Bergmann <arnd@arndb.de>, Logan Gunthorpe <logang@deltatee.com>

These are the first two common patches in my series to introduce
sparsemem support to RISC-V. The full series was posted last cycle
here [1] and the latest version can be found here [2].

As recommended by Palmer, I'd like to get the changes to common code
merged and then I will pursue the cleanups in the individual arches (arm,
arm64, and sh) as well as adding the new feature to riscv.

I would suggest we merge these two patches through Andrew's mm tree.

Thanks,

Logan

[1] https://lore.kernel.org/lkml/20181015175702.9036-1-logang@deltatee.com/T/#u
[2] https://github.com/sbates130272/linux-p2pmem.git riscv-sparsemem-v3

Logan Gunthorpe (2):
  mm: Introduce common STRUCT_PAGE_MAX_SHIFT define
  mm/sparse: add common helper to mark all memblocks present

 arch/arm64/include/asm/memory.h |  9 ---------
 arch/arm64/mm/init.c            |  8 --------
 include/asm-generic/fixmap.h    |  1 +
 include/linux/mm_types.h        |  5 +++++
 include/linux/mmzone.h          |  6 ++++++
 mm/sparse.c                     | 11 +++++++++++
 6 files changed, 23 insertions(+), 17 deletions(-)

--
2.19.0
