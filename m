Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 594AA6B0390
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 14:56:00 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id o126so137968399pfb.2
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 11:56:00 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id f30si9458167plf.93.2017.03.17.11.55.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 11:55:59 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/6] x86: 5-level paging enabling for v4.12, Part 2
Date: Fri, 17 Mar 2017 21:55:09 +0300
Message-Id: <20170317185515.8636-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Here's the second bunch of patches of 5-level patchset.

These patches finish switching x86 from <asm-generic/5level-fixup.h>
to <asm-generic/pgtable-nop4d.h>.

Please review and consider applying.

Kirill A. Shutemov (6):
  x86/kexec: Add 5-level paging support
  x86/efi: Add 5-level paging support
  x86/mm/pat: Add 5-level paging support
  x86/kasan: Prepare clear_pgds() to switch to
    <asm-generic/pgtable-nop4d.h>
  x86/xen: Change __xen_pgd_walk() and xen_cleanmfnmap() to support p4d
  x86: Convert the rest of the code to support p4d_t

 arch/x86/include/asm/kexec.h          |   1 +
 arch/x86/include/asm/paravirt.h       |  33 ++-
 arch/x86/include/asm/paravirt_types.h |  12 +-
 arch/x86/include/asm/pgalloc.h        |  35 ++-
 arch/x86/include/asm/pgtable.h        |  59 ++++-
 arch/x86/include/asm/pgtable_64.h     |  12 +-
 arch/x86/include/asm/pgtable_types.h  |  10 +-
 arch/x86/include/asm/xen/page.h       |   8 +-
 arch/x86/kernel/machine_kexec_32.c    |   4 +-
 arch/x86/kernel/machine_kexec_64.c    |  14 +-
 arch/x86/kernel/paravirt.c            |  10 +-
 arch/x86/mm/init_64.c                 | 183 ++++++++++++----
 arch/x86/mm/kasan_init_64.c           |  15 +-
 arch/x86/mm/pageattr.c                |  54 +++--
 arch/x86/platform/efi/efi_64.c        |  36 ++-
 arch/x86/xen/mmu.c                    | 397 ++++++++++++++++++++--------------
 arch/x86/xen/mmu.h                    |   1 +
 include/trace/events/xen.h            |  28 +--
 18 files changed, 646 insertions(+), 266 deletions(-)

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
