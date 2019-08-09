Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD947C32756
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 07:33:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9082F2166E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 07:33:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9082F2166E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C0C96B0005; Fri,  9 Aug 2019 03:33:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 172196B0006; Fri,  9 Aug 2019 03:33:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 039046B0007; Fri,  9 Aug 2019 03:33:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A88D36B0005
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 03:33:51 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id 63so664451edy.3
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 00:33:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=U0zOWSM5kXzgtNQC9x94T80gzHN/MW8QNfwriLBOnSc=;
        b=eKpyfcp6B92nROd9LCXXT2v7WmtzVOYf7otKxpDvJ70/HFpE43tQsVkGKucisTpzGk
         4LGxro1QiAybLsDT6oOtoWqvYrpGFZ5PpRMbT3idr1s75MfPPqU5q/xzQlvk6ig3GQSY
         wbuFlkbD0nH6WMW6U/+YfJJhrq0X/b0Lxf359zqPHHK+RqqTB3t2hTh0BMN6mOP7M29I
         hvTZGBvXCUI6WyamfZP6NDkaH/AyOttPLLuVONlrSZzbfyqnyn3mKOkh9f0pZw5ZiY2F
         U5LxarW8420xgYyqaaEqtBHomF8iJkwW3lGam/Hv68AdcR+etS+OJ5asxkW+gQTkeGwm
         oGvQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVtbNubg4e0ysg5Fg7Ig3n4jso4SM0uacnY35MFI1yLl5VaICnV
	pN9qLXP0QfTk+xts9tH+R8TM/mrD7Avbhh6adZvEjPIPxznSy1PlAtuBSGBDBSvTG3oCnLksEHy
	4aKAyGyjSqw6L3pv3MzcSKyROwvEtKm/qZXJirfdwVhyYFBhPmV+8/T0xFYigZqAyOg==
X-Received: by 2002:a17:906:1292:: with SMTP id k18mr17375856ejb.146.1565336031200;
        Fri, 09 Aug 2019 00:33:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqynvX8VuZ87xXrwVTif9HzgshytgM5TeDtCMHZgWdXywj4+XCQypmf9N2G6XoAgM0tQd63K
X-Received: by 2002:a17:906:1292:: with SMTP id k18mr17375814ejb.146.1565336030208;
        Fri, 09 Aug 2019 00:33:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565336030; cv=none;
        d=google.com; s=arc-20160816;
        b=sEwbx8G1xZYec6T+hMpHXVC9RRvnYwqN3cNkX+3oFKfADtqMCbZiB3Fqj6yTncxcIZ
         YN/Nm2xvLhIeJAltcM2mK5B1Nk4WgWi6Y0YS5C6hk6OuSVhsZlF7WzUiKfWvkHjSHd2/
         ZTQoKEsec+FtoCrT5JQOA7dXEL0W4xxJs91VKMoFqv1Y1DuJvzQ0X2Cm/RbADDfOOPC0
         24AV+p4otCaRo3zNixQsLMNLDkSwLaf4RXuTXEqEsHU25FAdO9N3O3kewF4KaGv4yqQ7
         bEuVqxcDAp7tJZ/thDW94532V6wI77tvgtJ8N81hPYECOLQOlArjUd5WNcphwlxdBMUj
         Ee1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=U0zOWSM5kXzgtNQC9x94T80gzHN/MW8QNfwriLBOnSc=;
        b=x4DKuEtTNLMvuU+C5W2JCRdJvpt67b7ZczE8oCovhwCz/uD/AELVBF9kGHv/HmrTnY
         4IKsDLITAAfJHmWdYxKWfelR2bAgTzs0h+w9Zm98OcfBrVb15WxrCMUqZDYl+1DoR4XJ
         uKbzx/4RgSZev9BMUGJbX9RDWSSyxVOxm7dSAQzI2M8veBYf9+3jiTX3E4fhOLRocL1v
         GbfYVmnrT/z2B1NAv5ECmgQuPlpKZ03lrKDuzyzim6dnKNOz6mdWujkAmADzV5dy/8ZE
         zc9jkwqsnO7l28r9ve4vGYkbLtDSpRXRFojR2GFkzVXlEZ0obZCf2OQ0oyzEkA52t91b
         XZ0w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id l42si37333555edc.120.2019.08.09.00.33.48
        for <linux-mm@kvack.org>;
        Fri, 09 Aug 2019 00:33:49 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 4D0D0344;
	Fri,  9 Aug 2019 00:33:48 -0700 (PDT)
Received: from p8cg001049571a15.arm.com (unknown [10.163.1.243])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 031723F706;
	Fri,  9 Aug 2019 00:33:31 -0700 (PDT)
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
Subject: [RFC V2 0/1] mm/debug: Add tests for architecture exported page table helpers
Date: Fri,  9 Aug 2019 13:03:17 +0530
Message-Id: <1565335998-22553-1-git-send-email-anshuman.khandual@arm.com>
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

Testing:

Build and boot tested on arm64 and x86 platforms. While arm64 clears all
these tests, following errors were reported on x86.

1. WARN_ON(pud_bad(pud)) in pud_populate_tests()
2. WARN_ON(p4d_bad(p4d)) in p4d_populate_tests()

I would really appreciate if folks can help validate this test on other
platforms and report back problems if any. Suggestions, comments and
inputs welcome. Thank you.

Changes in V2:

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
 mm/arch_pgtable_test.c | 400 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 415 insertions(+)
 create mode 100644 mm/arch_pgtable_test.c

-- 
2.20.1

