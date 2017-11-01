Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2D8766B0261
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 08:16:15 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b6so2098748pff.18
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 05:16:15 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id n7si818387pgq.39.2017.11.01.05.16.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 05:16:14 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/4] x86: 5-level related changes into decompression code
Date: Wed,  1 Nov 2017 14:54:59 +0300
Message-Id: <20171101115503.18358-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hi Ingo,

While we haven't yet closed on how to handle MAX_PHYSMEM_BITS situation,
could you look on changes into kernel decompression code?

These changes prepare the code to boot-time switching between paging modes
and handle booting in 5-level mode when bootloader put kernel image above
4G, but haven't enabled 5-level paging for us.

Please review and consider applying.

Kirill A. Shutemov (4):
  x86/boot/compressed/64: Compile pagetable.c unconditionally
  x86/boot/compressed/64: Detect and handle 5-level paging at boot-time
  x86/boot/compressed/64: Introduce place_trampoline()
  x86/boot/compressed/64: Handle 5-level paging boot if kernel is above
    4G

 arch/x86/boot/compressed/Makefile    |  2 +-
 arch/x86/boot/compressed/head_64.S   | 99 +++++++++++++++++++++++++-----------
 arch/x86/boot/compressed/pagetable.c | 66 ++++++++++++++++++++++++
 arch/x86/boot/compressed/pagetable.h | 18 +++++++
 4 files changed, 154 insertions(+), 31 deletions(-)
 create mode 100644 arch/x86/boot/compressed/pagetable.h

-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
