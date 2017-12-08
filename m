Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BE18B6B0253
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 08:10:31 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id e26so8776726pfi.15
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 05:10:31 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id a13si5457632pgt.35.2017.12.08.05.10.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Dec 2017 05:10:30 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 0/3] x86: 5-level related changes into decompression code
Date: Fri,  8 Dec 2017 16:09:19 +0300
Message-Id: <20171208130922.21488-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Here's few changes to x86 decompression code.

The first patch is pure cosmetic change: it gives file with KASLR helpers
a proper name.

The last two patches bring support of booting into 5-level paging mode if
a bootloader put the kernel above 4G.

Patch 2/3 handles allocation of space for trampoline and gets it prepared.
Patch 3/3 gets trampoline used.

Kirill A. Shutemov (3):
  x86/boot/compressed/64: Rename pagetable.c to kaslr_64.c
  x86/boot/compressed/64: Introduce place_trampoline()
  x86/boot/compressed/64: Handle 5-level paging boot if kernel is above
    4G

 arch/x86/boot/compressed/Makefile                  |   2 +-
 arch/x86/boot/compressed/head_64.S                 | 138 +++++++++++++--------
 .../boot/compressed/{pagetable.c => kaslr_64.c}    |   0
 arch/x86/boot/compressed/pgtable.h                 |  18 +++
 arch/x86/boot/compressed/pgtable_64.c              |  61 +++++++--
 5 files changed, 153 insertions(+), 66 deletions(-)
 rename arch/x86/boot/compressed/{pagetable.c => kaslr_64.c} (100%)
 create mode 100644 arch/x86/boot/compressed/pgtable.h

-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
