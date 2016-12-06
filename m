Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9B2826B025E
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 18:51:04 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id q128so303129720qkd.3
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 15:51:04 -0800 (PST)
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com. [209.85.220.174])
        by mx.google.com with ESMTPS id r63si12960483qkb.179.2016.12.06.15.51.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Dec 2016 15:51:03 -0800 (PST)
Received: by mail-qk0-f174.google.com with SMTP id n21so397660407qka.3
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 15:51:03 -0800 (PST)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCHv5 00/11] CONFIG_DEBUG_VIRTUAL for arm64
Date: Tue,  6 Dec 2016 15:50:46 -0800
Message-Id: <1481068257-6367-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>
Cc: Laura Abbott <labbott@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, xen-devel@lists.xenproject.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Vrabel <david.vrabel@citrix.com>, Juergen Gross <jgross@suse.com>, Eric Biederman <ebiederm@xmission.com>, kexec@lists.infradead.org, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, Andrey Ryabinin <aryabinin@virtuozzo.com>, Kees Cook <keescook@chromium.org>

Hi,

This is v5 of the series to add CONFIG_DEBUG_VIRTUAL for arm64. This mostly
contains minor fixups including adding a few extra headers around and splitting
things out into a few more sub-patches.

With a few more acks I think this should be ready to go. More testing is
always appreciated though.

Thanks,
Laura

Laura Abbott (11):
  lib/Kconfig.debug: Add ARCH_HAS_DEBUG_VIRTUAL
  mm/cma: Cleanup highmem check
  arm64: Move some macros under #ifndef __ASSEMBLY__
  arm64: Add cast for virt_to_pfn
  mm: Introduce lm_alias
  arm64: Use __pa_symbol for kernel symbols
  drivers: firmware: psci: Use __pa_symbol for kernel symbol
  kexec: Switch to __pa_symbol
  mm/kasan: Switch to using __pa_symbol and lm_alias
  mm/usercopy: Switch to using lm_alias
  arm64: Add support for CONFIG_DEBUG_VIRTUAL

 arch/arm64/Kconfig                        |  1 +
 arch/arm64/include/asm/kvm_mmu.h          |  4 +-
 arch/arm64/include/asm/memory.h           | 66 +++++++++++++++++++++----------
 arch/arm64/include/asm/mmu_context.h      |  6 +--
 arch/arm64/include/asm/pgtable.h          |  2 +-
 arch/arm64/kernel/acpi_parking_protocol.c |  3 +-
 arch/arm64/kernel/cpu-reset.h             |  2 +-
 arch/arm64/kernel/cpufeature.c            |  3 +-
 arch/arm64/kernel/hibernate.c             | 20 +++-------
 arch/arm64/kernel/insn.c                  |  2 +-
 arch/arm64/kernel/psci.c                  |  3 +-
 arch/arm64/kernel/setup.c                 |  9 +++--
 arch/arm64/kernel/smp_spin_table.c        |  3 +-
 arch/arm64/kernel/vdso.c                  |  8 +++-
 arch/arm64/mm/Makefile                    |  2 +
 arch/arm64/mm/init.c                      | 12 +++---
 arch/arm64/mm/kasan_init.c                | 22 +++++++----
 arch/arm64/mm/mmu.c                       | 33 ++++++++++------
 arch/arm64/mm/physaddr.c                  | 30 ++++++++++++++
 arch/x86/Kconfig                          |  1 +
 drivers/firmware/psci.c                   |  2 +-
 include/linux/mm.h                        |  4 ++
 kernel/kexec_core.c                       |  2 +-
 lib/Kconfig.debug                         |  5 ++-
 mm/cma.c                                  | 15 +++----
 mm/kasan/kasan_init.c                     | 15 +++----
 mm/usercopy.c                             |  4 +-
 27 files changed, 180 insertions(+), 99 deletions(-)
 create mode 100644 arch/arm64/mm/physaddr.c

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
