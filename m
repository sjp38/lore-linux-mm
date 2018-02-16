Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 89BC26B0003
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 06:49:55 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id l1so1976026pga.1
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 03:49:55 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id v3-v6si367116ply.829.2018.02.16.03.49.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Feb 2018 03:49:54 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/3] x86/mm/5lvl: Optimize boot-time switching, allow more Xen modes
Date: Fri, 16 Feb 2018 14:49:45 +0300
Message-Id: <20180216114948.68868-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This is the last batch of patches that enable boot-time switching
between paging modes.

The first patch allows two more Xen modes to be enabled with
CONFIG_X86_5LEVEL=y. These modes don't support 5-level paging,
but we can use them when boot into 4-level paging mode.

The last two patches optimize switching between paging modes by
using code pathching in all hot paths.

Please review and cosider applying.

Kirill A. Shutemov (3):
  x86/xen: Allow XEN_PV and XEN_PVH to be enabled with X86_5LEVEL
  x86/mm: Redefine some of page table helpers as macros
  x86/mm: Offset boot-time paging mode switching cost

 arch/x86/boot/compressed/misc.h         |  5 +++++
 arch/x86/entry/entry_64.S               | 11 ++---------
 arch/x86/include/asm/paravirt.h         | 23 +++++++++++++----------
 arch/x86/include/asm/pgtable_64_types.h |  5 ++++-
 arch/x86/kernel/head64.c                |  9 +++++++--
 arch/x86/kernel/head_64.S               | 14 +++++++-------
 arch/x86/mm/kasan_init_64.c             |  6 ++++++
 arch/x86/xen/Kconfig                    |  5 -----
 arch/x86/xen/mmu_pv.c                   | 21 +++++++++++++++++++++
 9 files changed, 65 insertions(+), 34 deletions(-)

-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
