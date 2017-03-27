Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id D2D016B0397
	for <linux-mm@kvack.org>; Mon, 27 Mar 2017 12:29:38 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id q189so70373011pgq.17
        for <linux-mm@kvack.org>; Mon, 27 Mar 2017 09:29:38 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id s1si1139574plj.269.2017.03.27.09.29.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Mar 2017 09:29:37 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/8] x86: 5-level paging enabling for v4.12, Part 3
Date: Mon, 27 Mar 2017 19:29:17 +0300
Message-Id: <20170327162925.16092-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Here's the third bunch of patches of 5-level patchset.

This time we prepare code to handle non-folded version of the additional page
table level.

Kirill A. Shutemov (8):
  x86/boot: Detect 5-level paging support
  x86/asm: Remove __VIRTUAL_MASK_SHIFT==47 assert
  x86/mm: Define virtual memory map for 5-level paging
  x86/paravirt: Make paravirt code support 5-level paging
  x86/mm: Add basic defines/helpers for CONFIG_X86_5LEVEL
  x86/dump_pagetables: Add support 5-level paging
  x86/kasan: Extend to support 5-level paging
  x86/espfix: Add support 5-level paging

 Documentation/x86/x86_64/mm.txt          | 33 +++++++++++++++++++--
 arch/x86/Kconfig                         |  1 +
 arch/x86/boot/cpucheck.c                 |  9 ++++++
 arch/x86/boot/cpuflags.c                 | 12 ++++++--
 arch/x86/entry/entry_64.S                |  7 ++---
 arch/x86/include/asm/disabled-features.h |  8 +++++-
 arch/x86/include/asm/kasan.h             |  9 ++++--
 arch/x86/include/asm/page_64_types.h     | 10 +++++++
 arch/x86/include/asm/paravirt.h          | 37 +++++++++++++++++-------
 arch/x86/include/asm/paravirt_types.h    |  7 ++++-
 arch/x86/include/asm/pgalloc.h           |  2 ++
 arch/x86/include/asm/pgtable_64.h        | 11 +++++++
 arch/x86/include/asm/pgtable_64_types.h  | 26 +++++++++++++++++
 arch/x86/include/asm/pgtable_types.h     | 10 ++++++-
 arch/x86/include/asm/required-features.h |  8 +++++-
 arch/x86/include/asm/sparsemem.h         |  9 ++++--
 arch/x86/kernel/espfix_64.c              | 12 ++++----
 arch/x86/kernel/paravirt.c               |  9 ++++--
 arch/x86/mm/dump_pagetables.c            | 49 +++++++++++++++++++++++++++-----
 arch/x86/mm/kasan_init_64.c              | 18 ++++++++++--
 arch/x86/mm/pgtable.c                    | 34 +++++++++++++++++++++-
 21 files changed, 274 insertions(+), 47 deletions(-)

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
