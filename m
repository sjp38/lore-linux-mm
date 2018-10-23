Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0B9C56B0003
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 12:32:10 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id f17-v6so942652plr.1
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 09:32:10 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id i70-v6si265925pge.224.2018.10.23.09.32.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Oct 2018 09:32:08 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/2] Fix couple of issues with LDT remap for PTI
Date: Tue, 23 Oct 2018 19:31:55 +0300
Message-Id: <20181023163157.41441-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The patchset fixes issues with LDT remap for PTI:

 - Layout collision due to KASLR with 5-level paging;

 - Information leak via Meltdown-like attack;

Please review and consider applying.

Kirill A. Shutemov (2):
  x86/mm: Move LDT remap out of KASLR region on 5-level paging
  x86/ldt: Unmap PTEs for the slow before freeing LDT

 Documentation/x86/x86_64/mm.txt         |  8 ++--
 arch/x86/include/asm/page_64_types.h    | 12 ++---
 arch/x86/include/asm/pgtable_64_types.h |  4 +-
 arch/x86/kernel/ldt.c                   | 59 ++++++++++++++++---------
 arch/x86/xen/mmu_pv.c                   |  6 +--
 5 files changed, 53 insertions(+), 36 deletions(-)

-- 
2.19.1
