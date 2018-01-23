Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id A0716800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 12:19:21 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id o4so1333759itf.5
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 09:19:21 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id y11si8578137itf.124.2018.01.23.09.19.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jan 2018 09:19:20 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 0/3] x86/mm/encrypt: Cleanup and switching between paging modes
Date: Tue, 23 Jan 2018 20:19:07 +0300
Message-Id: <20180123171910.55841-1-kirill.shutemov@linux.intel.com>
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

v2:
 - Rebased to up-to-date tip

Kirill A. Shutemov (3):
  x86/mm/encrypt: Move sme_populate_pgd*() into separate translation
    unit
  x86/mm/encrypt: Rewrite sme_populate_pgd() and
    sme_populate_pgd_large()
  x86/mm/encrypt: Rewrite sme_pgtable_calc()

 arch/x86/mm/Makefile               |  13 +--
 arch/x86/mm/mem_encrypt.c          | 171 +++----------------------------------
 arch/x86/mm/mem_encrypt_identity.c | 118 +++++++++++++++++++++++++
 arch/x86/mm/mm_internal.h          |  14 +++
 4 files changed, 152 insertions(+), 164 deletions(-)
 create mode 100644 arch/x86/mm/mem_encrypt_identity.c

-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
