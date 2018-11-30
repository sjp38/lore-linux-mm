Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 16BAA6B580F
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 06:58:06 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id bj3so3968522plb.17
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 03:58:06 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id z18si5232887plo.89.2018.11.30.03.58.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Nov 2018 03:58:04 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/2] Fixups for LDT remap placement change
Date: Fri, 30 Nov 2018 14:57:56 +0300
Message-Id: <20181130115758.4425-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org
Cc: boris.ostrovsky@oracle.com, jgross@suse.com, bhe@redhat.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

There's a couple fixes for the recent LDT remap placement change.

The first patch fixes crash when kernel booted as Xen dom0.

The second patch fixes address space markers in dump_pagetables output.
It's purely cosmetic change, backporting to the stable tree is optional.

Kirill A. Shutemov (2):
  x86/mm: Fix guard hole handling
  x86/dump_pagetables: Fix LDT remap address marker

 arch/x86/include/asm/pgtable_64_types.h |  5 +++++
 arch/x86/mm/dump_pagetables.c           | 15 ++++++---------
 arch/x86/xen/mmu_pv.c                   | 11 ++++++-----
 3 files changed, 17 insertions(+), 14 deletions(-)

-- 
2.19.2
