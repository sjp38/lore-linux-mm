Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id EE30E6B0033
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 06:47:24 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id j3so17629560pfh.16
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 03:47:24 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id f84si12781966pfh.71.2017.12.12.03.47.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Dec 2017 03:47:23 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/3] x86/mm/encrypt: Simplify pgtable helpers
Date: Tue, 12 Dec 2017 14:45:41 +0300
Message-Id: <20171212114544.56680-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, Borislav Petkov <bp@suse.de>, Brijesh Singh <brijesh.singh@amd.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patchset simplifies sme_populate_pgd(), sme_populate_pgd_large() and
sme_pgtable_calc() functions.

As a side effect, the patchset makes encryption code ready to boot-time
switching between paging modes.

The patchset is build on top of Tom's "x86: SME: BSP/SME microcode update
fix" patchset.

It was only build-tested. Tom, could you please get it tested properly?

Kirill A. Shutemov (3):
  x86/mm/encrypt: Move sme_populate_pgd*() into separate translation
    unit
  x86/mm/encrypt: Rewrite sme_populate_pgd() and
    sme_populate_pgd_large()
  x86/mm/encrypt: Rewrite sme_pgtable_calc()

 arch/x86/mm/Makefile               |  13 +--
 arch/x86/mm/mem_encrypt.c          | 169 ++++---------------------------------
 arch/x86/mm/mem_encrypt_identity.c | 123 +++++++++++++++++++++++++++
 arch/x86/mm/mm_internal.h          |   4 +
 4 files changed, 150 insertions(+), 159 deletions(-)
 create mode 100644 arch/x86/mm/mem_encrypt_identity.c

-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
