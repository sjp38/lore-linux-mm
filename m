Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6BD036B03B5
	for <linux-mm@kvack.org>; Sun, 16 Jul 2017 19:00:03 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y62so151363638pfa.3
        for <linux-mm@kvack.org>; Sun, 16 Jul 2017 16:00:03 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id d3si1193371pln.570.2017.07.16.16.00.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Jul 2017 16:00:02 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/8] 5-level paging enabling for v4.14
Date: Mon, 17 Jul 2017 01:59:46 +0300
Message-Id: <20170716225954.74185-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hi,

As Ingo requested, I'm resending the rebased patchset after merge window to be
queued for v4.14.

The patches was reordered and few more fixes added: for Xen and dump_pagetables.

Please consider applying.

Kirill A. Shutemov (8):
  x86/dump_pagetables: Generalize address normalization
  x86/dump_pagetables: Fix printout of p4d level
  x86/xen: Redefine XEN_ELFNOTE_INIT_P2M using PUD_SIZE * PTRS_PER_PUD
  x86/mm: Rename tasksize_32bit/64bit to task_size_32bit/64bit
  x86/mpx: Do not allow MPX if we have mappings above 47-bit
  x86/mm: Prepare to expose larger address space to userspace
  x86/mm: Allow userspace have mapping above 47-bit
  x86: Enable 5-level paging support

 Documentation/x86/x86_64/5level-paging.txt | 64 ++++++++++++++++++++++++++++++
 arch/x86/Kconfig                           | 18 +++++++++
 arch/x86/include/asm/elf.h                 |  4 +-
 arch/x86/include/asm/mpx.h                 |  9 +++++
 arch/x86/include/asm/processor.h           | 12 ++++--
 arch/x86/kernel/sys_x86_64.c               | 30 ++++++++++++--
 arch/x86/mm/dump_pagetables.c              | 29 +++++++-------
 arch/x86/mm/hugetlbpage.c                  | 27 +++++++++++--
 arch/x86/mm/mmap.c                         | 12 +++---
 arch/x86/mm/mpx.c                          | 33 ++++++++++++++-
 arch/x86/xen/Kconfig                       |  5 +++
 arch/x86/xen/xen-head.S                    |  2 +-
 12 files changed, 210 insertions(+), 35 deletions(-)
 create mode 100644 Documentation/x86/x86_64/5level-paging.txt

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
