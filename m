Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 76EF86B0069
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 18:26:04 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id c69so5969165qkg.1
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 15:26:04 -0800 (PST)
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com. [209.85.220.180])
        by mx.google.com with ESMTPS id s75si30647511qka.46.2017.01.03.15.26.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jan 2017 15:26:03 -0800 (PST)
Received: by mail-qk0-f180.google.com with SMTP id u25so380292128qki.2
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 15:26:03 -0800 (PST)
Subject: Re: [PATCHv6 00/11] CONFIG_DEBUG_VIRTUAL for arm64
References: <1483464113-1587-1-git-send-email-labbott@redhat.com>
 <edc8eaa2-5414-506c-1dad-f2404ef19c81@gmail.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <b3de65da-8a74-2510-268e-34516cc2de77@redhat.com>
Date: Tue, 3 Jan 2017 15:25:53 -0800
MIME-Version: 1.0
In-Reply-To: <edc8eaa2-5414-506c-1dad-f2404ef19c81@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Fainelli <f.fainelli@gmail.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, x86@kernel.org, kasan-dev@googlegroups.com, Ingo Molnar <mingo@redhat.com>, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, David Vrabel <david.vrabel@citrix.com>, Kees Cook <keescook@chromium.org>, Marc Zyngier <marc.zyngier@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, Eric Biederman <ebiederm@xmission.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoffer Dall <christoffer.dall@linaro.org>

On 01/03/2017 02:56 PM, Florian Fainelli wrote:
> On 01/03/2017 09:21 AM, Laura Abbott wrote:
>> Happy New Year!
>>
>> This is a very minor rebase from v5. It only moves a few headers around.
>> I think this series should be ready to be queued up for 4.11.
> 
> FWIW:
> 
> Tested-by: Florian Fainelli <f.fainelli@gmail.com>
> 

Thanks!

> How do we get this series included? I would like to get the ARM 32-bit
> counterpart included as well (will resubmit rebased shortly), but I have
> no clue which tree this should be going through.
> 

I was assuming this would go through the arm64 tree unless Catalin/Will
have an objection to that.

> Thanks!
> 
>>
>> Thanks,
>> Laura
>>
>> Laura Abbott (11):
>>   lib/Kconfig.debug: Add ARCH_HAS_DEBUG_VIRTUAL
>>   mm/cma: Cleanup highmem check
>>   arm64: Move some macros under #ifndef __ASSEMBLY__
>>   arm64: Add cast for virt_to_pfn
>>   mm: Introduce lm_alias
>>   arm64: Use __pa_symbol for kernel symbols
>>   drivers: firmware: psci: Use __pa_symbol for kernel symbol
>>   kexec: Switch to __pa_symbol
>>   mm/kasan: Switch to using __pa_symbol and lm_alias
>>   mm/usercopy: Switch to using lm_alias
>>   arm64: Add support for CONFIG_DEBUG_VIRTUAL
>>
>>  arch/arm64/Kconfig                        |  1 +
>>  arch/arm64/include/asm/kvm_mmu.h          |  4 +-
>>  arch/arm64/include/asm/memory.h           | 66 +++++++++++++++++++++----------
>>  arch/arm64/include/asm/mmu_context.h      |  6 +--
>>  arch/arm64/include/asm/pgtable.h          |  2 +-
>>  arch/arm64/kernel/acpi_parking_protocol.c |  3 +-
>>  arch/arm64/kernel/cpu-reset.h             |  2 +-
>>  arch/arm64/kernel/cpufeature.c            |  3 +-
>>  arch/arm64/kernel/hibernate.c             | 20 +++-------
>>  arch/arm64/kernel/insn.c                  |  2 +-
>>  arch/arm64/kernel/psci.c                  |  3 +-
>>  arch/arm64/kernel/setup.c                 |  9 +++--
>>  arch/arm64/kernel/smp_spin_table.c        |  3 +-
>>  arch/arm64/kernel/vdso.c                  |  8 +++-
>>  arch/arm64/mm/Makefile                    |  2 +
>>  arch/arm64/mm/init.c                      | 12 +++---
>>  arch/arm64/mm/kasan_init.c                | 22 +++++++----
>>  arch/arm64/mm/mmu.c                       | 33 ++++++++++------
>>  arch/arm64/mm/physaddr.c                  | 30 ++++++++++++++
>>  arch/x86/Kconfig                          |  1 +
>>  drivers/firmware/psci.c                   |  2 +-
>>  include/linux/mm.h                        |  4 ++
>>  kernel/kexec_core.c                       |  2 +-
>>  lib/Kconfig.debug                         |  5 ++-
>>  mm/cma.c                                  | 15 +++----
>>  mm/kasan/kasan_init.c                     | 15 +++----
>>  mm/usercopy.c                             |  4 +-
>>  27 files changed, 180 insertions(+), 99 deletions(-)
>>  create mode 100644 arch/arm64/mm/physaddr.c
>>
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
