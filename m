Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A11C96B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 15:44:09 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id n13so4876501wmc.3
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 12:44:09 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id z63si8759900wmz.126.2017.11.27.12.44.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 27 Nov 2017 12:44:08 -0800 (PST)
Message-Id: <20171127203416.236563829@linutronix.de>
Date: Mon, 27 Nov 2017 21:34:16 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 0/4] x86/kaiser: Paravirt support and various fixlets
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at, Juergen Gross <jgross@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

The series contains the following changes against

  git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git WIP.x86/asm

 - Remove the flush_tlb_single paravirt patching. It's not longer INVPCID
   anymore. Especially not with KAISER enabled.

 - Remove the !PARAVIRT dependency of KAISER and just disable it at boot
   time when the kernel runs as XEN_PV guest.

 - Address a few review comments.

Thanks,

	tglx
---
 arch/x86/include/asm/hypervisor.h   |   25 +++++++++++++++----------
 arch/x86/kernel/paravirt_patch_64.c |    2 --
 arch/x86/mm/debug_pagetables.c      |    6 +++---
 arch/x86/mm/dump_pagetables.c       |    6 ++++--
 arch/x86/mm/kaiser.c                |    3 +++
 security/Kconfig                    |    2 +-
 6 files changed, 26 insertions(+), 18 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
