Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1B6FF6B025E
	for <linux-mm@kvack.org>; Fri, 29 Sep 2017 10:08:30 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u136so3651956pgc.5
        for <linux-mm@kvack.org>; Fri, 29 Sep 2017 07:08:30 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id l18si3450613pfb.281.2017.09.29.07.08.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Sep 2017 07:08:28 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/6] Boot-time switching between 4- and 5-level paging for 4.15, Part 1
Date: Fri, 29 Sep 2017 17:08:15 +0300
Message-Id: <20170929140821.37654-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The first bunch of patches that prepare kernel to boot-time switching
between paging modes.

Please review and consider applying.

Andrey Ryabinin (1):
  x86/kasan: Use the same shadow offset for 4- and 5-level paging

Kirill A. Shutemov (5):
  mm/sparsemem: Allocate mem_section at runtime for SPARSEMEM_EXTREME
  mm/zsmalloc: Prepare to variable MAX_PHYSMEM_BITS
  x86/xen: Provide pre-built page tables only for XEN_PV and XEN_PVH
  x86/xen: Drop 5-level paging support code from XEN_PV code
  x86/boot/compressed/64: Detect and handle 5-level paging at boot-time

 Documentation/x86/x86_64/mm.txt             |   2 +-
 arch/x86/Kconfig                            |   1 -
 arch/x86/boot/compressed/head_64.S          |  26 ++++-
 arch/x86/include/asm/pgtable-3level_types.h |   1 +
 arch/x86/include/asm/pgtable_64_types.h     |   2 +
 arch/x86/kernel/Makefile                    |   3 +-
 arch/x86/kernel/head_64.S                   |  11 +-
 arch/x86/mm/kasan_init_64.c                 | 101 ++++++++++++++----
 arch/x86/xen/mmu_pv.c                       | 159 +++++++++++-----------------
 include/linux/mmzone.h                      |   6 +-
 mm/page_alloc.c                             |  10 ++
 mm/sparse.c                                 |  17 +--
 mm/zsmalloc.c                               |  13 +--
 13 files changed, 210 insertions(+), 142 deletions(-)

-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
