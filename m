Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id EB21E6B038A
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 20:17:01 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id b123so7184317itb.3
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 17:17:01 -0800 (PST)
Received: from mail-it0-f50.google.com (mail-it0-f50.google.com. [209.85.214.50])
        by mx.google.com with ESMTPS id p3si4104734iof.179.2016.11.17.17.17.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 17:17:01 -0800 (PST)
Received: by mail-it0-f50.google.com with SMTP id j191so7048994ita.1
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 17:17:01 -0800 (PST)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCHv3 0/6] CONFIG_DEBUG_VIRTUAL for arm64
Date: Thu, 17 Nov 2016 17:16:50 -0800
Message-Id: <1479431816-5028-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>
Cc: Laura Abbott <labbott@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org

Hi,

This is v3 of the series to add CONFIG_DEBUG_VIRTUAL for arm64.
The biggest change from v2 is the conversion of more __pa sites
to __pa_symbol for stricter checks.

With that expansion, having this go through the arm64 tree is going to be
easiest so I'd like to start getting Acks from x86 and mm maintainers.

Thanks,
Laura

Laura Abbott (6):
  lib/Kconfig.debug: Add ARCH_HAS_DEBUG_VIRTUAL
  mm/cma: Cleanup highmem check
  arm64: Move some macros under #ifndef __ASSEMBLY__
  arm64: Add cast for virt_to_pfn
  arm64: Use __pa_symbol for kernel symbols
  arm64: Add support for CONFIG_DEBUG_VIRTUAL

 arch/arm64/Kconfig                        |  1 +
 arch/arm64/include/asm/kvm_mmu.h          |  4 +-
 arch/arm64/include/asm/memory.h           | 70 ++++++++++++++++++++++---------
 arch/arm64/include/asm/mmu_context.h      |  6 +--
 arch/arm64/include/asm/pgtable.h          |  2 +-
 arch/arm64/kernel/acpi_parking_protocol.c |  2 +-
 arch/arm64/kernel/cpufeature.c            |  2 +-
 arch/arm64/kernel/hibernate.c             |  9 ++--
 arch/arm64/kernel/insn.c                  |  2 +-
 arch/arm64/kernel/psci.c                  |  2 +-
 arch/arm64/kernel/setup.c                 |  8 ++--
 arch/arm64/kernel/smp_spin_table.c        |  2 +-
 arch/arm64/kernel/vdso.c                  |  4 +-
 arch/arm64/mm/Makefile                    |  1 +
 arch/arm64/mm/init.c                      | 11 ++---
 arch/arm64/mm/mmu.c                       | 24 +++++------
 arch/arm64/mm/physaddr.c                  | 39 +++++++++++++++++
 arch/x86/Kconfig                          |  1 +
 drivers/firmware/psci.c                   |  2 +-
 lib/Kconfig.debug                         |  5 ++-
 mm/cma.c                                  | 15 +++----
 21 files changed, 140 insertions(+), 72 deletions(-)
 create mode 100644 arch/arm64/mm/physaddr.c

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
