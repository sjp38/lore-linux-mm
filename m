Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id BE9DF6B46DE
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 10:57:38 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id b29-v6so1091659pfm.1
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 07:57:38 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x18-v6si1128374pll.88.2018.08.28.07.57.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 Aug 2018 07:57:37 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 00/10] Push the vm_fault_t conversion further
Date: Tue, 28 Aug 2018 07:57:18 -0700
Message-Id: <20180828145728.11873-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This patch series reaps some of the benefits of the vm_fault_t work that
Souptick has been diligently plugging away at by converting insert_pfn()
to return a vm_fault_t.

Eventually, we'll be able to do the same thing to insert_page(),
but there's more work to be done converting all current callers of
vm_insert_page() to vmf_insert_page(), and this patch series provides
a nice clean-up.

Nicolas, I'd like your reviewed-by on patch 1 please.

Matthew Wilcox (10):
  cramfs: Convert to use vmf_insert_mixed
  mm: Remove vm_insert_mixed
  mm: Introduce vmf_insert_pfn_prot
  x86: Convert vdso to use vm_fault_t
  mm: Make vm_insert_pfn_prot static
  mm: Remove references to vm_insert_pfn
  mm: Remove vm_insert_pfn
  mm: Inline vm_insert_pfn_prot into caller
  mm: Convert __vm_insert_mixed to vm_fault_t
  mm: Convert insert_pfn to vm_fault_t

 Documentation/x86/pat.txt     |   4 +-
 arch/x86/entry/vdso/vma.c     |  24 +++----
 fs/cramfs/inode.c             |   9 ++-
 include/asm-generic/pgtable.h |   4 +-
 include/linux/hmm.h           |   2 +-
 include/linux/mm.h            |  32 +--------
 mm/memory.c                   | 122 +++++++++++++++++-----------------
 7 files changed, 84 insertions(+), 113 deletions(-)

-- 
2.18.0
