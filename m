Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3B8F96B0005
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 13:57:17 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id m7-v6so19501456iop.9
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 10:57:17 -0700 (PDT)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id q124-v6si7177309iod.118.2018.10.15.10.57.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 15 Oct 2018 10:57:16 -0700 (PDT)
From: Logan Gunthorpe <logang@deltatee.com>
Date: Mon, 15 Oct 2018 11:56:56 -0600
Message-Id: <20181015175702.9036-1-logang@deltatee.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Subject: [PATCH v2 0/6] sparsemem support for RISC-V
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-riscv@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org
Cc: Stephen Bates <sbates@raithlin.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <aou@eecs.berkeley.edu>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Logan Gunthorpe <logang@deltatee.com>

This patchset implements sparsemem on RISC-V. The first few patches
move some code in existing architectures into common helpers
so they can be used by the new RISC-V implementation. The final
patch actually adds sparsmem support to RISC-V.

This is the first small step in supporting P2P on RISC-V.

--

Changes in v2:

* Rebase on v4.19-rc8
* Move the STRUCT_PAGE_MAX_SHIFT define into a common header (near
  the definition of struct page). As suggested by Christoph.
* Clean up the unnecessary nid variable in the memblocks_present()
  function, per Christoph.
* Collected tags from Palmer and Catalin.

--
Logan Gunthorpe (6):
  mm: Introduce common STRUCT_PAGE_MAX_SHIFT define
  mm/sparse: add common helper to mark all memblocks present
  ARM: mm: make use of new memblocks_present() helper
  arm64: mm: make use of new memblocks_present() helper
  sh: mm: make use of new memblocks_present() helper
  RISC-V: Implement sparsemem

 arch/arm/mm/init.c                 | 17 +----------------
 arch/arm64/include/asm/memory.h    |  9 ---------
 arch/arm64/mm/init.c               | 28 +---------------------------
 arch/riscv/Kconfig                 | 23 +++++++++++++++++++++++
 arch/riscv/include/asm/pgtable.h   | 21 +++++++++++++++++----
 arch/riscv/include/asm/sparsemem.h | 11 +++++++++++
 arch/riscv/kernel/setup.c          |  4 +++-
 arch/riscv/mm/init.c               |  8 ++++++++
 arch/sh/mm/init.c                  |  7 +------
 include/asm-generic/fixmap.h       |  1 +
 include/linux/mm_types.h           |  5 +++++
 include/linux/mmzone.h             |  6 ++++++
 mm/sparse.c                        | 14 ++++++++++++++
 13 files changed, 91 insertions(+), 63 deletions(-)
 create mode 100644 arch/riscv/include/asm/sparsemem.h

--
2.19.0
