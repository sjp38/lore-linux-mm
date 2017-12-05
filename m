Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2A56F6B0069
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 09:00:02 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id g8so191596pgs.14
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 06:00:02 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id z64si137467pfa.207.2017.12.05.06.00.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 06:00:00 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 0/4] x86: 5-level related changes into decompression code
Date: Tue,  5 Dec 2017 16:59:38 +0300
Message-Id: <20171205135942.24634-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hi,

Here's few changes to x86 decompression code.

The first patch fixes build regression introduced by my recent patch.
It only triggers when KASLR disabled and GCC version < 5. I haven't
noticed this before.

The second patch is pure cosmetic change: give file with KASLR helpers
a proper name.

The last two patches bring support of booting into 5-level paging mode if
a bootloader put the kernel above 4G.

Patch 3/4 handles allocation of space for trampoline and gets it prepared.
Patch 4/4 gets trampoline used.

Please review and consider applying.

Kirill A. Shutemov (4):
  x86/boot/compressed/64: Fix build with GCC < 5
  x86/boot/compressed/64: Rename pagetable.c to kaslr_64.c
  x86/boot/compressed/64: Introduce place_trampoline()
  x86/boot/compressed/64: Handle 5-level paging boot if kernel is above
    4G

 arch/x86/boot/compressed/Makefile                  |   2 +-
 arch/x86/boot/compressed/head_64.S                 | 130 +++++++++++++--------
 .../boot/compressed/{pagetable.c => kaslr_64.c}    |   3 -
 arch/x86/boot/compressed/pgtable.h                 |  18 +++
 arch/x86/boot/compressed/pgtable_64.c              |  75 ++++++++++--
 5 files changed, 163 insertions(+), 65 deletions(-)
 rename arch/x86/boot/compressed/{pagetable.c => kaslr_64.c} (97%)
 create mode 100644 arch/x86/boot/compressed/pgtable.h

-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
