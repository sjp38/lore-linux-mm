Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id DAA9F6B0287
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 08:51:32 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id e6-v6so2609569pge.5
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 05:51:32 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id x186-v6si4812465pfx.19.2018.10.24.05.51.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Oct 2018 05:51:31 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 0/2] Fix couple of issues with LDT remap for PTI
Date: Wed, 24 Oct 2018 15:51:10 +0300
Message-Id: <20181024125112.55999-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org
Cc: boris.ostrovsky@oracle.com, jgross@suse.com, bhe@redhat.com, willy@infradead.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The patchset fixes issues with LDT remap for PTI:

 - Layout collision due to KASLR with 5-level paging;

 - Information leak via Meltdown-like attack;

Please review and consider applying.

v2:
 - Rebase to the Linus' tree
   + fix conflict with new documentation of kernel memory layout
   + fix few mistakes in layout documentation
 - Fix typo in commit message

Kirill A. Shutemov (2):
  x86/mm: Move LDT remap out of KASLR region on 5-level paging
  x86/ldt: Unmap PTEs for the slot before freeing LDT pages

 Documentation/x86/x86_64/mm.txt         | 34 +++++++-------
 arch/x86/include/asm/page_64_types.h    | 12 ++---
 arch/x86/include/asm/pgtable_64_types.h |  4 +-
 arch/x86/kernel/ldt.c                   | 59 ++++++++++++++++---------
 arch/x86/xen/mmu_pv.c                   |  6 +--
 5 files changed, 67 insertions(+), 48 deletions(-)

-- 
2.19.1
