Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id DFE1D6B0006
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 10:42:29 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id h193so10348378pfe.14
        for <linux-mm@kvack.org>; Tue, 27 Feb 2018 07:42:29 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id v7si5208946pfi.403.2018.02.27.07.42.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Feb 2018 07:42:28 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 0/5] x86/boot/compressed/64: Prepare trampoline memory
Date: Tue, 27 Feb 2018 18:42:12 +0300
Message-Id: <20180227154217.69347-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Here's re-split of the patch that prepares trampoline memory, but doesn't
actually uses it yet. The original patch turned out to be problematic.

The functionality should match the original patch (although I've moved a
bit more into C).

Please review and consider applying.

v2:
 - Add Tested-by from Borislav
 - s/__ASSEMBLER__/__ASSEMBLY__/

Kirill A. Shutemov (5):
  x86/boot/compressed/64: Describe the logic behind LA57 check
  x86/boot/compressed/64: Find a place for 32-bit trampoline
  x86/boot/compressed/64: Save and restore trampoline memory
  x86/boot/compressed/64: Set up trampoline memory
  x86/boot/compressed/64: Prepare new top-level page table for
    trampoline

 arch/x86/boot/compressed/head_64.S    |  13 +++-
 arch/x86/boot/compressed/misc.c       |   4 +
 arch/x86/boot/compressed/pgtable.h    |  20 +++++
 arch/x86/boot/compressed/pgtable_64.c | 133 +++++++++++++++++++++++++++++++++-
 4 files changed, 166 insertions(+), 4 deletions(-)
 create mode 100644 arch/x86/boot/compressed/pgtable.h

-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
