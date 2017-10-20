Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 453296B025F
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 16:00:11 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v78so11500758pfk.8
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 13:00:11 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id z33si937319plb.555.2017.10.20.13.00.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 13:00:10 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/4] Boot-time switching between 4- and 5-level paging for 4.15, Part 2
Date: Fri, 20 Oct 2017 22:59:30 +0300
Message-Id: <20171020195934.32108-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hi Ingo,

Here's the second bunch of patches that prepare kernel to boot-time switching
between paging modes.

It's a small one. I hope we can get it in quick. :)

I include the zsmalloc patch again. We need something to address the issue.
If we would find a better solution, we can come back to the topic and
rework it.

Apart from zsmalloc patch, the patchset includes changes to decompression
code. I reworked these patches. They are split not exactly the way you've
described before, but I hope it's sensible anyway.

Please review and consider applying.

Kirill A. Shutemov (4):
  mm/zsmalloc: Prepare to variable MAX_PHYSMEM_BITS
  x86/boot/compressed/64: Detect and handle 5-level paging at boot-time
  x86/boot/compressed/64: Introduce place_trampoline()
  x86/boot/compressed/64: Handle 5-level paging boot if kernel is above 4G

 arch/x86/boot/compressed/head_64.S          | 99 ++++++++++++++++++++---------
 arch/x86/boot/compressed/pagetable.c        | 61 ++++++++++++++++++
 arch/x86/boot/compressed/pagetable.h        | 18 ++++++
 arch/x86/include/asm/pgtable-3level_types.h |  1 +
 arch/x86/include/asm/pgtable_64_types.h     |  2 +
 mm/zsmalloc.c                               | 13 ++--
 6 files changed, 158 insertions(+), 36 deletions(-)
 create mode 100644 arch/x86/boot/compressed/pagetable.h

-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
