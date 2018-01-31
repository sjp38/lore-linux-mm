Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 47F166B0005
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 08:54:17 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id a9so14744437pff.0
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 05:54:17 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id u69si11202675pgb.10.2018.01.31.05.54.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jan 2018 05:54:15 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 0/3] x86/mm/encrypt: Cleanup and switching between paging modes<Paste>
Date: Wed, 31 Jan 2018 16:54:01 +0300
Message-Id: <20180131135404.40692-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patcheset is a preparation set for boot-time switching between
paging modes. Please review and consider applying.

Code around sme_populate_pgd() is unnecessary complex and hard to modify.

This patchset rewrites it in more stream-lined way to add support of
boot-time switching between paging modes.

I haven't tested the patchset on hardware capable of memory encryption.

v4:
 - Move sev_enabled declaration to <linux/mem_encrypt.h>
 - Fix few typos in commit messages
 - Reviewed/Tested-by from Tom
v3:
 - Move all page table related functions into mem_encrypt_identity.c
v2:
 - Rebased to up-to-date tip

Kirill A. Shutemov (3):
  x86/mm/encrypt: Move page table helpers into separate translation unit
  x86/mm/encrypt: Rewrite sme_populate_pgd() and
    sme_populate_pgd_large()
  x86/mm/encrypt: Rewrite sme_pgtable_calc()

 arch/x86/include/asm/mem_encrypt.h |   1 +
 arch/x86/mm/Makefile               |  14 +-
 arch/x86/mm/mem_encrypt.c          | 578 +------------------------------------
 arch/x86/mm/mem_encrypt_identity.c | 564 ++++++++++++++++++++++++++++++++++++
 4 files changed, 575 insertions(+), 582 deletions(-)
 create mode 100644 arch/x86/mm/mem_encrypt_identity.c

-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
