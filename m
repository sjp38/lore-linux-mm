Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 79F026B028C
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 07:42:08 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id t65so13009841pfe.22
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 04:42:08 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id w11si10197345pfa.211.2017.12.04.04.42.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Dec 2017 04:42:07 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 0/5] x86: 5-level related changes into decompression code
Date: Mon,  4 Dec 2017 15:40:54 +0300
Message-Id: <20171204124059.63515-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hi Ingo,

Here's updated changes that prepare the code to boot-time switching between
paging modes and handle booting in 5-level mode when bootloader put kernel
image above 4G, but haven't enabled 5-level paging for us.

First two patches can be backported to v4.14 to provide sensible error
message when CONFIG_X86_5LEVEL=y kernel is booted on hardware that doesn't
support the feature.

Please review and consider applying.

Kirill A. Shutemov (5):
  x86/boot/compressed/64: Detect and handle 5-level paging at boot-time
  x86/boot/compressed/64: Print error if 5-level paging is not supported
  x86/boot/compressed/64: Rename pagetable.c to kaslr_64.c
  x86/boot/compressed/64: Introduce place_trampoline()
  x86/boot/compressed/64: Handle 5-level paging boot if kernel is above
    4G

 arch/x86/boot/compressed/Makefile                  |   3 +-
 arch/x86/boot/compressed/head_64.S                 | 108 +++++++++++++--------
 .../boot/compressed/{pagetable.c => kaslr_64.c}    |   0
 arch/x86/boot/compressed/misc.c                    |  16 +++
 arch/x86/boot/compressed/pgtable.h                 |  18 ++++
 arch/x86/boot/compressed/pgtable_64.c              |  61 ++++++++++++
 6 files changed, 166 insertions(+), 40 deletions(-)
 rename arch/x86/boot/compressed/{pagetable.c => kaslr_64.c} (100%)
 create mode 100644 arch/x86/boot/compressed/pgtable.h
 create mode 100644 arch/x86/boot/compressed/pgtable_64.c

-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
