Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id D9CC66B0292
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 00:41:42 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id z19so5607969oia.13
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 21:41:42 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l197si1889831oib.40.2017.07.24.21.41.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 21:41:41 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v5 0/2] x86/mm: PCID
Date: Mon, 24 Jul 2017 21:41:37 -0700
Message-Id: <cover.1500957502.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>

Here's PCID v5.

Changes from v4:
 - Remove smp_mb__after_atomic() (Peterz)
 - Rebase, which involved tiny fixups due to SME
 - Add the doc patch, as promised

Andy Lutomirski (2):
  x86/mm: Try to preserve old TLB entries using PCID
  x86/mm: Improve TLB flush documentation

 arch/x86/include/asm/mmu_context.h     |   3 +
 arch/x86/include/asm/processor-flags.h |   2 +
 arch/x86/include/asm/tlbflush.h        |  18 ++++-
 arch/x86/mm/init.c                     |   1 +
 arch/x86/mm/tlb.c                      | 123 ++++++++++++++++++++++++++-------
 5 files changed, 119 insertions(+), 28 deletions(-)

-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
