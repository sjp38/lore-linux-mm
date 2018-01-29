Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 83BB46B0005
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 06:54:01 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id r1so4573101pgt.19
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 03:54:01 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 39-v6si9168213plc.289.2018.01.29.03.53.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jan 2018 03:54:00 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv7 0/4] x86: 5-level related changes into decompression code
Date: Mon, 29 Jan 2018 14:53:47 +0300
Message-Id: <20180129115351.85224-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

These patcheset is a preparation for boot-time switching between paging
modes. Please apply.

The first patch is pure cosmetic change: it gives file with KASLR helpers
a proper name.

The last three patches bring support of booting into 5-level paging mode if
a bootloader put the kernel above 4G.

Patch 2/4 Renames l5_paging_required() into paging_prepare() and change
interface of the function.
Patch 3/4 Handles allocation of space for trampoline and gets it prepared.
Patch 4/4 Gets trampoline used.

v7:
 - Fix booting when 5-level paging is enabled before handing off boot to
   the kernel, like in kexec() case.

Kirill A. Shutemov (4):
  x86/boot/compressed/64: Rename pagetable.c to kaslr_64.c
  x86/boot/compressed/64: Introduce paging_prepare()
  x86/boot/compressed/64: Prepare trampoline memory
  x86/boot/compressed/64: Handle 5-level paging boot if kernel is above 4G

 arch/x86/boot/compressed/Makefile                  |   2 +-
 arch/x86/boot/compressed/head_64.S                 | 147 +++++++++++++--------
 .../boot/compressed/{pagetable.c => kaslr_64.c}    |   0
 arch/x86/boot/compressed/pgtable.h                 |  18 +++
 arch/x86/boot/compressed/pgtable_64.c              |  66 +++++++--
 5 files changed, 168 insertions(+), 65 deletions(-)
 rename arch/x86/boot/compressed/{pagetable.c => kaslr_64.c} (100%)
 create mode 100644 arch/x86/boot/compressed/pgtable.h

-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
