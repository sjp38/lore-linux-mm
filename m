Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id EA7FB6B59F3
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 15:23:51 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 68so5327402pfr.6
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 12:23:51 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id m3si6242816pld.331.2018.11.30.12.23.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Nov 2018 12:23:50 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 0/2] Fixups for LDT remap placement change
Date: Fri, 30 Nov 2018 23:23:26 +0300
Message-Id: <20181130202328.65359-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org
Cc: boris.ostrovsky@oracle.com, jgross@suse.com, bhe@redhat.com, hans.van.kranenburg@mendix.com, x86@kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

There's a couple fixes for the recent LDT remap placement change.

The first patch fixes crash when kernel booted as Xen dom0.

The second patch fixes address space markers in dump_pagetables output.
It's purely cosmetic change, backporting to the stable tree is optional.

v2:
 - Fix typo

Kirill A. Shutemov (2):
  x86/mm: Fix guard hole handling
  x86/dump_pagetables: Fix LDT remap address marker

 arch/x86/include/asm/pgtable_64_types.h |  5 +++++
 arch/x86/mm/dump_pagetables.c           | 15 ++++++---------
 arch/x86/xen/mmu_pv.c                   | 11 ++++++-----
 3 files changed, 17 insertions(+), 14 deletions(-)

-- 
2.19.2
