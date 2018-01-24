Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E22E1800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 11:36:37 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id b4so2753113pgs.5
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 08:36:37 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id k69si322515pgd.749.2018.01.24.08.36.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jan 2018 08:36:36 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 0/3] x86/mm/encrypt: Cleanup and switching between paging modes
Date: Wed, 24 Jan 2018 19:36:20 +0300
Message-Id: <20180124163623.61765-1-kirill.shutemov@linux.intel.com>
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

v3:
 - Move all page table related functions into mem_encrypt_identity.c
v2:
 - Rebased to up-to-date tip

Kirill A. Shutemov (3):
  x86/mm/encrypt: Move page table helpers into separate translation unit
  x86/mm/encrypt: Rewrite sme_populate_pgd() and
    sme_populate_pgd_large()
  x86/mm/encrypt: Rewrite sme_pgtable_calc()

 arch/x86/mm/Makefile               |  14 +-
 arch/x86/mm/mem_encrypt.c          | 578 +------------------------------------
 arch/x86/mm/mem_encrypt_identity.c | 563 ++++++++++++++++++++++++++++++++++++
 arch/x86/mm/mm_internal.h          |   1 +
 4 files changed, 574 insertions(+), 582 deletions(-)
 create mode 100644 arch/x86/mm/mem_encrypt_identity.c

-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
