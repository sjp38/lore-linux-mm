Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id C826B6B026D
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 23:10:27 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id i17so17030910otb.2
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 20:10:27 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r32si13234582oth.265.2017.11.27.20.10.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 20:10:26 -0800 (PST)
From: Josh Poimboeuf <jpoimboe@redhat.com>
Subject: [PATCH 0/2] x86/mm/kaiser: a couple of KAISER mapping fixes
Date: Mon, 27 Nov 2017 22:10:11 -0600
Message-Id: <cover.1511842148.git.jpoimboe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

On top of the tip KAISER patches.

Josh Poimboeuf (2):
  x86/mm/kaiser: Remove unused user-mapped page-aligned section
  x86/mm/kaiser: Don't map the IRQ stack in user space

 include/asm-generic/vmlinux.lds.h |  6 ++----
 include/linux/percpu-defs.h       | 10 ----------
 2 files changed, 2 insertions(+), 14 deletions(-)

-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
