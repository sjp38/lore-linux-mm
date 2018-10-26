Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8C0E26B030D
	for <linux-mm@kvack.org>; Fri, 26 Oct 2018 08:29:04 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id bb3-v6so484180plb.20
        for <linux-mm@kvack.org>; Fri, 26 Oct 2018 05:29:04 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id c23-v6si10537010pls.348.2018.10.26.05.29.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Oct 2018 05:29:03 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 0/3] Fix couple of issues with LDT remap for PTI
Date: Fri, 26 Oct 2018 15:28:53 +0300
Message-Id: <20181026122856.66224-1-kirill.shutemov@linux.intel.com>
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

v3:
 - Split out cleanup in map_ldt_struct() into a separate patch
v2:
 - Rebase to the Linus' tree
   + fix conflict with new documentation of kernel memory layout
   + fix few mistakes in layout documentation
 - Fix typo in commit message

Kirill A. Shutemov (3):
  x86/mm: Move LDT remap out of KASLR region on 5-level paging
  x86/ldt: Unmap PTEs for the slot before freeing LDT pages
  x86/ldt: Remove unused variable in map_ldt_struct()

 Documentation/x86/x86_64/mm.txt         | 34 +++++++-------
 arch/x86/include/asm/page_64_types.h    | 12 ++---
 arch/x86/include/asm/pgtable_64_types.h |  4 +-
 arch/x86/kernel/ldt.c                   | 59 ++++++++++++++++---------
 arch/x86/xen/mmu_pv.c                   |  6 +--
 5 files changed, 67 insertions(+), 48 deletions(-)

-- 
2.19.1
