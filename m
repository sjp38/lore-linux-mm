Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B2A426B038D
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 10:33:32 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id j5so302034194pfb.3
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 07:33:32 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 184si2805425pga.29.2017.03.13.07.33.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Mar 2017 07:33:31 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/6] x86: 5-level paging enabling for v4.12, Part 1
Date: Mon, 13 Mar 2017 17:33:03 +0300
Message-Id: <20170313143309.16020-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Here's the first bunch of patches of 5-level patchset. Let's see if I'm on
right track addressing Ingo's feedback. :)

These patches prepare x86 code to be switched from <asm-generic/5level-fixup>
to <asm-generic/pgtable-nop4d.h>. It's a stepping stone for adding 5-level
paging support.

Please review and consider applying.

Kirill A. Shutemov (6):
  x86/mm: Extend headers with basic definitions to support 5-level
    paging
  x86/mm: Convert trivial cases of page table walk to 5-level paging
  x86/gup: Add 5-level paging support
  x86/ident_map: Add 5-level paging support
  x86/vmalloc: Add 5-level paging support
  x86/power: Add 5-level paging support

 arch/x86/include/asm/pgtable-2level_types.h |  1 +
 arch/x86/include/asm/pgtable-3level_types.h |  1 +
 arch/x86/include/asm/pgtable.h              | 26 +++++++++---
 arch/x86/include/asm/pgtable_64_types.h     |  1 +
 arch/x86/include/asm/pgtable_types.h        | 30 ++++++++++++-
 arch/x86/kernel/tboot.c                     |  6 ++-
 arch/x86/kernel/vm86_32.c                   |  6 ++-
 arch/x86/mm/fault.c                         | 66 +++++++++++++++++++++++++----
 arch/x86/mm/gup.c                           | 33 ++++++++++++---
 arch/x86/mm/ident_map.c                     | 51 +++++++++++++++++++---
 arch/x86/mm/init_32.c                       | 22 +++++++---
 arch/x86/mm/ioremap.c                       |  3 +-
 arch/x86/mm/pgtable.c                       |  4 +-
 arch/x86/mm/pgtable_32.c                    |  8 +++-
 arch/x86/platform/efi/efi_64.c              | 13 ++++--
 arch/x86/power/hibernate_32.c               |  7 ++-
 arch/x86/power/hibernate_64.c               | 50 ++++++++++++++++------
 17 files changed, 269 insertions(+), 59 deletions(-)

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
