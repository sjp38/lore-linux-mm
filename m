Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6CE7F2802A1
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 17:07:27 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id g75so8739442pfg.4
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 14:07:27 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id j8si9961662pli.503.2017.11.10.14.07.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Nov 2017 14:07:26 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 0/4] x86: 5-level related changes into decompression code
Date: Sat, 11 Nov 2017 01:06:41 +0300
Message-Id: <20171110220645.59944-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hi Ingo,

Here's updated changes that prepare the code to boot-time switching between
paging modes and handle booting in 5-level mode when bootloader put kernel
image above 4G, but haven't enabled 5-level paging for us.

I've updated patches based on your feedback.

Please review and consider applying.

Kirill A. Shutemov (4):
  x86/boot/compressed/64: Rename pagetable.c to kaslr_64.c
  x86/boot/compressed/64: Detect and handle 5-level paging at boot-time
  x86/boot/compressed/64: Introduce place_trampoline()
  x86/boot/compressed/64: Handle 5-level paging boot if kernel is above
    4G

 arch/x86/boot/compressed/Makefile                  |   3 +-
 arch/x86/boot/compressed/head_64.S                 | 108 +++++++++++++--------
 .../boot/compressed/{pagetable.c => kaslr_64.c}    |   0
 arch/x86/boot/compressed/pgtable.h                 |  18 ++++
 arch/x86/boot/compressed/pgtable_64.c              |  61 ++++++++++++
 5 files changed, 150 insertions(+), 40 deletions(-)
 rename arch/x86/boot/compressed/{pagetable.c => kaslr_64.c} (100%)
 create mode 100644 arch/x86/boot/compressed/pgtable.h
 create mode 100644 arch/x86/boot/compressed/pgtable_64.c

-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
