Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 644676B0315
	for <linux-mm@kvack.org>; Mon, 15 May 2017 08:13:00 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id y65so101186835pff.13
        for <linux-mm@kvack.org>; Mon, 15 May 2017 05:13:00 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id v69si10633527pfk.110.2017.05.15.05.12.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 05:12:59 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5, REBASED 0/9] x86: 5-level paging enabling for v4.12, Part 4
Date: Mon, 15 May 2017 15:12:09 +0300
Message-Id: <20170515121218.27610-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Here's rebased version the fourth and the last bunch of of patches that brings
initial 5-level paging enabling.

Please review and consider applying.

Kirill A. Shutemov (9):
  x86/asm: Fix comment in return_from_SYSCALL_64
  x86/boot/64: Rewrite startup_64 in C
  x86/boot/64: Rename init_level4_pgt and early_level4_pgt
  x86/boot/64: Add support of additional page table level during early
    boot
  x86/mm: Add sync_global_pgds() for configuration with 5-level paging
  x86/mm: Make kernel_physical_mapping_init() support 5-level paging
  x86/mm: Add support for 5-level paging for KASLR
  x86: Enable 5-level paging support
  x86/mm: Allow to have userspace mappings above 47-bits

 arch/x86/Kconfig                            |   5 +
 arch/x86/boot/compressed/head_64.S          |  23 ++++-
 arch/x86/entry/entry_64.S                   |   3 +-
 arch/x86/include/asm/elf.h                  |   4 +-
 arch/x86/include/asm/mpx.h                  |   9 ++
 arch/x86/include/asm/pgtable.h              |   2 +-
 arch/x86/include/asm/pgtable_64.h           |   6 +-
 arch/x86/include/asm/processor.h            |  11 ++-
 arch/x86/include/uapi/asm/processor-flags.h |   2 +
 arch/x86/kernel/espfix_64.c                 |   2 +-
 arch/x86/kernel/head64.c                    | 143 +++++++++++++++++++++++++---
 arch/x86/kernel/head_64.S                   | 134 ++++++--------------------
 arch/x86/kernel/machine_kexec_64.c          |   2 +-
 arch/x86/kernel/sys_x86_64.c                |  30 +++++-
 arch/x86/mm/dump_pagetables.c               |   2 +-
 arch/x86/mm/hugetlbpage.c                   |  27 +++++-
 arch/x86/mm/init_64.c                       | 108 +++++++++++++++++++--
 arch/x86/mm/kasan_init_64.c                 |  12 +--
 arch/x86/mm/kaslr.c                         |  81 ++++++++++++----
 arch/x86/mm/mmap.c                          |   6 +-
 arch/x86/mm/mpx.c                           |  33 ++++++-
 arch/x86/realmode/init.c                    |   2 +-
 arch/x86/xen/Kconfig                        |   1 +
 arch/x86/xen/mmu_pv.c                       |  18 ++--
 arch/x86/xen/xen-pvh.S                      |   2 +-
 25 files changed, 480 insertions(+), 188 deletions(-)

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
