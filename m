Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 864F46B000C
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 12:16:48 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id d194-v6so2699791itb.8
        for <linux-mm@kvack.org>; Fri, 05 Oct 2018 09:16:48 -0700 (PDT)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id s77-v6si6284203jad.70.2018.10.05.09.16.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 05 Oct 2018 09:16:46 -0700 (PDT)
From: Logan Gunthorpe <logang@deltatee.com>
Date: Fri,  5 Oct 2018 10:16:37 -0600
Message-Id: <20181005161642.2462-1-logang@deltatee.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Subject: [PATCH 0/5] sparsemem support for RISC-V
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-riscv@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org
Cc: Stephen Bates <sbates@raithlin.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <aou@eecs.berkeley.edu>, Christoph Hellwig <hch@lst.de>, Logan Gunthorpe <logang@deltatee.com>

Hi Everyone,

This patchset is intended to implement sparsemem on RISC-V.
The first few patches are introducing a common helper used by the
sparesmem implementation in other architectures and the final
patch is the actual RISC-V implementation.

This is the first small step in supporting P2P on RISC-V.

Thanks,

Logan

--

Logan Gunthorpe (5):
  mm/sparse: add common helper to mark all memblocks present
  ARM: mm: make use of new memblocks_present() helper
  arm64: mm: make use of new memblocks_present() helper
  sh: mm: make use of new memblocks_present() helper
  RISC-V: Implement sparsemem

 arch/arm/mm/init.c                 | 17 +----------------
 arch/arm64/mm/init.c               | 20 +-------------------
 arch/riscv/Kconfig                 | 23 +++++++++++++++++++++++
 arch/riscv/include/asm/pgtable.h   | 24 ++++++++++++++++++++----
 arch/riscv/include/asm/sparsemem.h | 11 +++++++++++
 arch/riscv/kernel/setup.c          |  4 +++-
 arch/riscv/mm/init.c               |  8 ++++++++
 arch/sh/mm/init.c                  |  7 +------
 include/linux/mmzone.h             |  6 ++++++
 mm/sparse.c                        | 15 +++++++++++++++
 10 files changed, 89 insertions(+), 46 deletions(-)
 create mode 100644 arch/riscv/include/asm/sparsemem.h

--
2.19.0
