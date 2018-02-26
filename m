Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E61896B000D
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 13:05:04 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q2so5818721pgf.22
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 10:05:04 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id g7-v6si7004759plt.91.2018.02.26.10.05.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 10:05:03 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/5] x86/boot/compressed/64: Prepare trampoline memory
Date: Mon, 26 Feb 2018 21:04:46 +0300
Message-Id: <20180226180451.86788-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Here's re-split of the patch that prepares trampoline memory, but doesn't
actually uses it yet. The original patch turned out to be problematic.
Splitting the patch should help to pin down the issue.

The functionality should match the original patch (although I've moved a
bit more into C).

Borislav, could you check which patch breaks boot for you (if any)?

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
