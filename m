Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2AE446B002C
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 13:42:38 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id b17so7608998otf.16
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 10:42:38 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s205si604983oif.368.2018.02.20.10.42.36
        for <linux-mm@kvack.org>;
        Tue, 20 Feb 2018 10:42:37 -0800 (PST)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [PATCH 00/11] APEI in_nmi() rework and arm64 SDEI wire-up
References: <20180215185606.26736-1-james.morse@arm.com>
Date: Tue, 20 Feb 2018 18:42:34 +0000
In-Reply-To: <20180215185606.26736-1-james.morse@arm.com> (James Morse's
	message of "Thu, 15 Feb 2018 18:55:55 +0000")
Message-ID: <87a7w3zen9.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>

James Morse <james.morse@arm.com> writes:

> Hello!

Hi

>
> The aim of this series is to wire arm64's SDEI into APEI.
>

[...]

>
> Trees... The changes outside APEI are tiny, but there will be some changes
> to how arch/arm64/mm/fault.c generates signals, affecting do_sea() that will
> cause conflicts with patch 5.

All but the last patch applied cleanly on v4.16-rc2 for me.

Other than the comments I've already sent the patches look good to me.

FWIW,

Reviewed-by: Punit Agrawal <punit.agrawal@arm.com>

Thanks,
Punit

>
>
> Thanks,
>
> James
>
> [0] http://infocenter.arm.com/help/topic/com.arm.doc.den0054a/ARM_DEN0054A_Software_Delegated_Exception_Interface.pdf
>
> James Morse (11):
>   ACPI / APEI: Move the estatus queue code up, and under its own ifdef
>   ACPI / APEI: Generalise the estatus queue's add/remove and notify code
>   ACPI / APEI: Switch NOTIFY_SEA to use the estatus queue
>   KVM: arm/arm64: Add kvm_ras.h to collect kvm specific RAS plumbing
>   arm64: KVM/mm: Move SEA handling behind a single 'claim' interface
>   ACPI / APEI: Make the fixmap_idx per-ghes to allow multiple in_nmi()
>     users
>   ACPI / APEI: Split fixmap pages for arm64 NMI-like notifications
>   firmware: arm_sdei: Add ACPI GHES registration helper
>   ACPI / APEI: Add support for the SDEI GHES Notification type
>   mm/memory-failure: increase queued recovery work's priority
>   arm64: acpi: Make apei_claim_sea() synchronise with APEI's irq work
>
>  arch/arm/include/asm/kvm_ras.h       |  14 +
>  arch/arm/include/asm/system_misc.h   |   5 -
>  arch/arm64/include/asm/acpi.h        |   3 +
>  arch/arm64/include/asm/daifflags.h   |   1 +
>  arch/arm64/include/asm/fixmap.h      |   8 +-
>  arch/arm64/include/asm/kvm_ras.h     |  29 ++
>  arch/arm64/include/asm/system_misc.h |   2 -
>  arch/arm64/kernel/acpi.c             |  49 ++++
>  arch/arm64/mm/fault.c                |  30 +-
>  drivers/acpi/apei/ghes.c             | 533 ++++++++++++++++++++---------------
>  drivers/firmware/arm_sdei.c          |  75 +++++
>  include/acpi/ghes.h                  |   5 +
>  include/linux/arm_sdei.h             |   8 +
>  mm/memory-failure.c                  |  11 +-
>  virt/kvm/arm/mmu.c                   |   4 +-
>  15 files changed, 517 insertions(+), 260 deletions(-)
>  create mode 100644 arch/arm/include/asm/kvm_ras.h
>  create mode 100644 arch/arm64/include/asm/kvm_ras.h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
