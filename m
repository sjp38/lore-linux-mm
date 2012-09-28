Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id D171E6B006C
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 19:36:50 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/3] Virtual huge zero page
Date: Sat, 29 Sep 2012 02:37:18 +0300
Message-Id: <1348875441-19561-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, "H. Peter Anvin" <hpa@linux.intel.com>
Cc: Andi Kleen <ak@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Here's alternative implementation of huge zero page: virtual huge zero
page.

Virtual huge zero page is a PMD table with all entries set to zero page.
H. Peter Anvin asked to evaluate this implementation option.

Pros:
 - cache friendly (not yet benchmarked);
 - less changes required (if I haven't miss something ;);

Cons:
 - increases TLB pressure;
 - requires per-arch enabling;
 - one more check on handle_mm_fault() path.

At the moment I did only sanity check. Testing is required.

Any opinion?

Kirill A. Shutemov (3):
  asm-generic: introduce pmd_special() and pmd_mkspecial()
  mm, thp: implement virtual huge zero page
  x86: implement HAVE_PMD_SPECAIL

 arch/Kconfig                   |    6 ++++++
 arch/x86/Kconfig               |    1 +
 arch/x86/include/asm/pgtable.h |   14 +++++++++++++-
 include/asm-generic/pgtable.h  |   12 ++++++++++++
 include/linux/mm.h             |    8 ++++++++
 mm/huge_memory.c               |   38 ++++++++++++++++++++++++++++++++++++++
 mm/memory.c                    |   15 ++++++++-------
 7 files changed, 86 insertions(+), 8 deletions(-)

-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
