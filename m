Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2C7DC10F14
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 14:56:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D80120818
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 14:56:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D80120818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA98D6B029B; Wed, 10 Apr 2019 10:56:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D300D6B029C; Wed, 10 Apr 2019 10:56:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C211A6B029D; Wed, 10 Apr 2019 10:56:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6E84E6B029B
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 10:56:46 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y7so1403409eds.7
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 07:56:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=6Pfr8BVyDlTGVnhBhPR1Vhm8qmqyUDDDwFfasXLaybI=;
        b=F2Bk2ByPEDgxKpHCgml9Rit/+fmmv3vtlPHWLH9shHY0th3shEvSZa4k7htuakF3Q0
         kLK4+XtfpT2bUcIFcUvBzrBwFBSgzKrnqmoXF26njeQSsEoO93XS9Mx1WnccASA4jeaT
         8kpTM8plb1T8Ow4FP0yLvHtfKfQAlQ1UULHziKNDdhPriEcCsVIi64xbxz0+6YUcesFb
         Qeq5JxXnu5QndJZQxisrzkQxBH+rTO2CtHjdu75NwjQAfxlE1RxXX7H36rEhz6xyO8Vz
         VomDOd2qdxDAJd97nruhSjJGDYNxRnwqBp5abnq6FfsN5Ch9dNdwuEUHOusV1yJdA19W
         YIIg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAVB2lqIu2KAFVJbp7tefJQg3ITiU6Xz0jp/bIOCsTpF0MGqS+iM
	tZ81Ab4aIxBr+ne00L0UnHLrqpWpF6HgB0rB/YPLoCUjEWxR/FywBEZXGC6yLF+4PItKxGTMOff
	7waCYkiXv1AfhDzdBjUFZYkn4tCynEKS/yD7OlsGhi4OHUKE32slM7VLoP2Tox99QpQ==
X-Received: by 2002:aa7:c750:: with SMTP id c16mr16648284eds.35.1554908205912;
        Wed, 10 Apr 2019 07:56:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyCl0rUh9Jbujjdo9LeRDk2ULhLpQMMEY/gDbozqtwOWM9hcFgCGDmIDxoEnwr3jjyvwfk+
X-Received: by 2002:aa7:c750:: with SMTP id c16mr16648220eds.35.1554908204639;
        Wed, 10 Apr 2019 07:56:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554908204; cv=none;
        d=google.com; s=arc-20160816;
        b=DKPmthA0nlGm2zWy0kl2YSaUPgpAGI/m/rkDV1wQ/XStqxVUFnwmYegnY2CEJHxNDa
         JkPZE7bwlQnQ69wx3KBFr60CNVQsdpaDhJcUOeRri0DJaq/ruKSM9CFo+HwL89e03UKP
         MZyJgU+EVM3XK+6Op90VsGProYFLShtEDCVx18GrD7qtprwvymNNoILtcnNXD91+2KIN
         ben6XJNNhN+LTGCakXZL5jxunqjUVGLd/N/8ngCxH9yjntB+QKSgKEfkOJpf4xLabgSK
         vhUdOLIaV4ceJNDIJOROsmLUNX9LIBKkRQ7woL58nWu2I2Al6TUqc5GNuoJ1aGzPE2f+
         xTaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=6Pfr8BVyDlTGVnhBhPR1Vhm8qmqyUDDDwFfasXLaybI=;
        b=JbKlkOwdZ7pmN2MoYkq+jDcwAiq+lBwwCnhQilKzd5ctYOMVgAH7Sbq6avZeeJS4QZ
         Rp5tmauN/gan5QRa7NnFcH+AI91i8L1oun/ApUHdLfd6Lut+8uSGT/pjI/lGXPTlhC2F
         i/m/vCPuWeAgoXNeirEapj41aqM/RNxIaCrEBgECSHM5RTJMD+9amLBPWKtBtI0US71I
         CzImE/fvqCi+Xp50edipUgroOEMTa5IvegiQpU9u0YTVWy/cBGR+LLqQnW1L+9p7BVcb
         Nj2yba1VJSu/J1zPA2ks3cAPszxVMddl0pmO1tVHsaEFtPSXnAvi3ZrKfIMf7zrltq7b
         Vu/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y5si262855edh.418.2019.04.10.07.56.44
        for <linux-mm@kvack.org>;
        Wed, 10 Apr 2019 07:56:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6FA2D374;
	Wed, 10 Apr 2019 07:56:43 -0700 (PDT)
Received: from [10.1.196.69] (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id F11813F557;
	Wed, 10 Apr 2019 07:56:39 -0700 (PDT)
Subject: Re: [PATCH v8 00/20] Convert x86 & arm64 to use generic page walk
To: linux-mm@kvack.org
Cc: Mark Rutland <Mark.Rutland@arm.com>, x86@kernel.org,
 Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon
 <will.deacon@arm.com>, linux-kernel@vger.kernel.org,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
 Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
 James Morse <james.morse@arm.com>, Thomas Gleixner <tglx@linutronix.de>,
 Andrew Morton <akpm@linux-foundation.org>,
 linux-arm-kernel@lists.infradead.org, "Liang, Kan"
 <kan.liang@linux.intel.com>
References: <20190403141627.11664-1-steven.price@arm.com>
From: Steven Price <steven.price@arm.com>
Message-ID: <4e804c87-1788-8903-ccc9-55953aa6da36@arm.com>
Date: Wed, 10 Apr 2019 15:56:38 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190403141627.11664-1-steven.price@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

Gentle ping: who can take this? Is there anything blocking this series?

Thanks,

Steve

On 03/04/2019 15:16, Steven Price wrote:
> Most architectures current have a debugfs file for dumping the kernel
> page tables. Currently each architecture has to implement custom
> functions for walking the page tables because the generic
> walk_page_range() function is unable to walk the page tables used by the
> kernel.
> 
> This series extends the capabilities of walk_page_range() so that it can
> deal with the page tables of the kernel (which have no VMAs and can
> contain larger huge pages than exist for user space). x86 and arm64 are
> then converted to make use of walk_page_range() removing the custom page
> table walkers.
> 
> To enable a generic page table walker to walk the unusual mappings of
> the kernel we need to implement a set of functions which let us know
> when the walker has reached the leaf entry. Since arm, powerpc, s390,
> sparc and x86 all have p?d_large macros lets standardise on that and
> implement those that are missing.
> 
> Potentially future changes could unify the implementations of the
> debugfs walkers further, moving the common functionality into common
> code. This would require a common way of handling the effective
> permissions (currently implemented only for x86) along with a per-arch
> way of formatting the page table information for debugfs. One
> immediate benefit would be getting the KASAN speed up optimisation in
> arm64 (and other arches) which is currently only implemented for x86.
> 
> Also available as a git tree:
> git://linux-arm.org/linux-sp.git walk_page_range/v8
> 
> Changes since v7:
> https://lore.kernel.org/lkml/20190328152104.23106-1-steven.price@arm.com/T/
>  * Updated commit message in patch 2 to clarify that we rely on the page
>    tables being walked to be the same page size/depth as the kernel's
>    (since this confused me earlier today).
> 
> Changes since v6:
> https://lore.kernel.org/lkml/20190326162624.20736-1-steven.price@arm.com/T/
>  * Split the changes for powerpc. pmd_large() is now added in patch 4
>    patch, and pmd_is_leaf() removed in patch 5.
> 
> Changes since v5:
> https://lore.kernel.org/lkml/20190321141953.31960-1-steven.price@arm.com/T/
>  * Updated comment for struct mm_walk based on Mike Rapoport's
>    suggestion
> 
> Changes since v4:
> https://lore.kernel.org/lkml/20190306155031.4291-1-steven.price@arm.com/T/
>  * Correctly force result to a boolean in p?d_large for powerpc.
>  * Added Acked-bys
>  * Rebased onto v5.1-rc1
> 
> Changes since v3:
> https://lore.kernel.org/lkml/20190227170608.27963-1-steven.price@arm.com/T/
>  * Restored the generic macros, only implement p?d_large() for
>    architectures that have support for large pages. This also means
>    adding dummy #defines for architectures that define p?d_large as
>    static inline to avoid picking up the generic macro.
>  * Drop the 'depth' argument from pte_hole
>  * Because we no longer have the depth for holes, we also drop support
>    in x86 for showing missing pages in debugfs. See discussion below:
>    https://lore.kernel.org/lkml/26df02dd-c54e-ea91-bdd1-0a4aad3a30ac@arm.com/
>  * mips: only define p?d_large when _PAGE_HUGE is defined.
> 
> Changes since v2:
> https://lore.kernel.org/lkml/20190221113502.54153-1-steven.price@arm.com/T/
>  * Rather than attemping to provide generic macros, actually implement
>    p?d_large() for each architecture.
> 
> Changes since v1:
> https://lore.kernel.org/lkml/20190215170235.23360-1-steven.price@arm.com/T/
>  * Added p4d_large() macro
>  * Comments to explain p?d_large() macro semantics
>  * Expanded comment for pte_hole() callback to explain mapping between
>    depth and P?D
>  * Handle folded page tables at all levels, so depth from pte_hole()
>    ignores folding at any level (see real_depth() function in
>    mm/pagewalk.c)
> 
> Steven Price (20):
>   arc: mm: Add p?d_large() definitions
>   arm64: mm: Add p?d_large() definitions
>   mips: mm: Add p?d_large() definitions
>   powerpc: mm: Add p?d_large() definitions
>   KVM: PPC: Book3S HV: Remove pmd_is_leaf()
>   riscv: mm: Add p?d_large() definitions
>   s390: mm: Add p?d_large() definitions
>   sparc: mm: Add p?d_large() definitions
>   x86: mm: Add p?d_large() definitions
>   mm: Add generic p?d_large() macros
>   mm: pagewalk: Add p4d_entry() and pgd_entry()
>   mm: pagewalk: Allow walking without vma
>   mm: pagewalk: Add test_p?d callbacks
>   arm64: mm: Convert mm/dump.c to use walk_page_range()
>   x86: mm: Don't display pages which aren't present in debugfs
>   x86: mm: Point to struct seq_file from struct pg_state
>   x86: mm+efi: Convert ptdump_walk_pgd_level() to take a mm_struct
>   x86: mm: Convert ptdump_walk_pgd_level_debugfs() to take an mm_struct
>   x86: mm: Convert ptdump_walk_pgd_level_core() to take an mm_struct
>   x86: mm: Convert dump_pagetables to use walk_page_range
> 
>  arch/arc/include/asm/pgtable.h               |   1 +
>  arch/arm64/include/asm/pgtable.h             |   2 +
>  arch/arm64/mm/dump.c                         | 117 +++----
>  arch/mips/include/asm/pgtable-64.h           |   8 +
>  arch/powerpc/include/asm/book3s/64/pgtable.h |  30 +-
>  arch/powerpc/kvm/book3s_64_mmu_radix.c       |  12 +-
>  arch/riscv/include/asm/pgtable-64.h          |   7 +
>  arch/riscv/include/asm/pgtable.h             |   7 +
>  arch/s390/include/asm/pgtable.h              |   2 +
>  arch/sparc/include/asm/pgtable_64.h          |   2 +
>  arch/x86/include/asm/pgtable.h               |  10 +-
>  arch/x86/mm/debug_pagetables.c               |   8 +-
>  arch/x86/mm/dump_pagetables.c                | 347 ++++++++++---------
>  arch/x86/platform/efi/efi_32.c               |   2 +-
>  arch/x86/platform/efi/efi_64.c               |   4 +-
>  include/asm-generic/pgtable.h                |  19 +
>  include/linux/mm.h                           |  26 +-
>  mm/pagewalk.c                                |  76 +++-
>  18 files changed, 407 insertions(+), 273 deletions(-)
> 

