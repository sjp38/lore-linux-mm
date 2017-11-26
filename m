Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id BF1416B0069
	for <linux-mm@kvack.org>; Sun, 26 Nov 2017 13:10:14 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id y42so16769354wrd.23
        for <linux-mm@kvack.org>; Sun, 26 Nov 2017 10:10:14 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id t9si16276894wra.449.2017.11.26.10.10.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 26 Nov 2017 10:10:13 -0800 (PST)
Message-Id: <20171126175538.841453476@linutronix.de>
Date: Sun, 26 Nov 2017 18:55:38 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 0/4] x86/kaiser: Boot time disabling and debug support
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

This patch series applies on top of

     git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git WIP.x86/mm

It contains the following updates:

  - Get rid of the compile time PAGE_GLOBAL disabling

  - Add debug support for WX mappings in the KAISER shadow table

  - Provide debug files to dump the kernel and the user page table for the
    current task.

  - Add a boot time switch to disable KAISER. This does not yet take care of
    the 8k PGD allocations, but that can be done on top.

Thanks,

	tglx

---
 arch/x86/entry/calling.h             |    7 +++
 arch/x86/include/asm/kaiser.h        |    8 +++
 arch/x86/include/asm/pgtable.h       |    1 
 arch/x86/include/asm/pgtable_64.h    |    6 ++
 arch/x86/include/asm/pgtable_types.h |   16 ------
 arch/x86/mm/debug_pagetables.c       |   81 ++++++++++++++++++++++++++++++++---
 arch/x86/mm/dump_pagetables.c        |   27 +++++++++--
 arch/x86/mm/init.c                   |   14 ++++--
 arch/x86/mm/kaiser.c                 |   30 ++++++++++++
 arch/x86/mm/pageattr.c               |   16 +++---
 security/Kconfig                     |    2 
 11 files changed, 170 insertions(+), 38 deletions(-)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
