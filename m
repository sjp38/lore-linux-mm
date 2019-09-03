Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84962C3A5A5
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 08:02:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 44AE52377D
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 08:02:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44AE52377D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC43E6B0003; Tue,  3 Sep 2019 04:02:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A6016B0005; Tue,  3 Sep 2019 04:02:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 65D096B0006; Tue,  3 Sep 2019 04:02:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0049.hostedemail.com [216.40.44.49])
	by kanga.kvack.org (Postfix) with ESMTP id 2F7CB6B0003
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 04:02:06 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id B15CF181AC9B6
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 08:02:05 +0000 (UTC)
X-FDA: 75892866210.27.teeth17_696cdb3c1121c
X-HE-Tag: teeth17_696cdb3c1121c
X-Filterd-Recvd-Size: 7252
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf12.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 08:02:04 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 3B2FD344;
	Tue,  3 Sep 2019 01:02:03 -0700 (PDT)
Received: from p8cg001049571a15.blr.arm.com (p8cg001049571a15.blr.arm.com [10.162.42.170])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 312113F246;
	Tue,  3 Sep 2019 01:01:52 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-mm@kvack.org
Cc: Anshuman Khandual <anshuman.khandual@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Dan Williams <dan.j.williams@intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Mark Brown <broonie@kernel.org>,
	Steven Price <Steven.Price@arm.com>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Kees Cook <keescook@chromium.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Matthew Wilcox <willy@infradead.org>,
	Sri Krishna chowdary <schowdary@nvidia.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Russell King - ARM Linux <linux@armlinux.org.uk>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Paul Mackerras <paulus@samba.org>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Vineet Gupta <vgupta@synopsys.com>,
	James Hogan <jhogan@kernel.org>,
	Paul Burton <paul.burton@mips.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	linux-snps-arc@lists.infradead.org,
	linux-mips@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	x86@kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 0/1] mm/debug: Add tests for architecture exported page table helpers
Date: Tue,  3 Sep 2019 13:31:45 +0530
Message-Id: <1567497706-8649-1-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This series adds a test validation for architecture exported page table
helpers. Patch in the series adds basic transformation tests at various
levels of the page table.

This test was originally suggested by Catalin during arm64 THP migration
RFC discussion earlier. Going forward it can include more specific tests
with respect to various generic MM functions like THP, HugeTLB etc and
platform specific tests.

https://lore.kernel.org/linux-mm/20190628102003.GA56463@arrakis.emea.arm.com/

Questions:

Should alloc_gigantic_page() be made available as an interface for general
use in the kernel. The test module here uses very similar implementation from
HugeTLB to allocate a PUD aligned memory block. Similar for mm_alloc() which
needs to be exported through a header.

Matthew Wilcox had expressed concerns regarding memory allocation for mapped
page table entries at various level. He also suggested using synethetic pfns
which can be derived from virtual address of a known kernel text symbol like
kernel_init(). But as discussed previously, it seems like allocated memory
might still outweigh synthetic pfns. This proposal goes with allocated memory
but if there is a broader agreement with respect to synthetic pfns, will be
happy to rework the test.

Testing:

Build and boot tested on arm64 and x86 platforms. While arm64 clears all
these tests, following errors were reported on x86.

1. WARN_ON(pud_bad(pud)) in pud_populate_tests()
2. WARN_ON(p4d_bad(p4d)) in p4d_populate_tests()

I would really appreciate if folks can help validate this test on other
platforms and report back problems if any. Suggestions, comments and
inputs welcome. Thank you.

Changes in V3:

- Added fallback mechanism for PMD aligned memory allocation failure

Changes in V2:

https://lore.kernel.org/linux-mm/1565335998-22553-1-git-send-email-anshuman.khandual@arm.com/T/#u

- Moved test module and it's config from lib/ to mm/
- Renamed config TEST_ARCH_PGTABLE as DEBUG_ARCH_PGTABLE_TEST
- Renamed file from test_arch_pgtable.c to arch_pgtable_test.c
- Added relevant MODULE_DESCRIPTION() and MODULE_AUTHOR() details
- Dropped loadable module config option
- Basic tests now use memory blocks with required size and alignment
- PUD aligned memory block gets allocated with alloc_contig_range()
- If PUD aligned memory could not be allocated it falls back on PMD aligned
  memory block from page allocator and pud_* tests are skipped
- Clear and populate tests now operate on real in memory page table entries
- Dummy mm_struct gets allocated with mm_alloc()
- Dummy page table entries get allocated with [pud|pmd|pte]_alloc_[map]()
- Simplified [p4d|pgd]_basic_tests(), now has random values in the entries

RFC V1:

https://lore.kernel.org/linux-mm/1564037723-26676-1-git-send-email-anshuman.khandual@arm.com/

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Mark Brown <broonie@kernel.org>
Cc: Steven Price <Steven.Price@arm.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Sri Krishna chowdary <schowdary@nvidia.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Russell King - ARM Linux <linux@armlinux.org.uk>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Vineet Gupta <vgupta@synopsys.com>
Cc: James Hogan <jhogan@kernel.org>
Cc: Paul Burton <paul.burton@mips.com>
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: linux-snps-arc@lists.infradead.org
Cc: linux-mips@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-ia64@vger.kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-s390@vger.kernel.org
Cc: linux-sh@vger.kernel.org
Cc: sparclinux@vger.kernel.org
Cc: x86@kernel.org
Cc: linux-kernel@vger.kernel.org

Anshuman Khandual (1):
  mm/pgtable/debug: Add test validating architecture page table helpers

 mm/Kconfig.debug       |  14 ++
 mm/Makefile            |   1 +
 mm/arch_pgtable_test.c | 425 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 440 insertions(+)
 create mode 100644 mm/arch_pgtable_test.c

-- 
2.20.1


