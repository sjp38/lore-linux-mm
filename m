Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1E2FB6B0269
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 13:18:09 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id l204-v6so8584468oia.17
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 10:18:09 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 123-v6si850330oii.193.2018.10.12.10.18.07
        for <linux-mm@kvack.org>;
        Fri, 12 Oct 2018 10:18:08 -0700 (PDT)
Subject: Re: [PATCH v6 06/18] KVM: arm/arm64: Add kvm_ras.h to collect kvm
 specific RAS plumbing
References: <20180921221705.6478-1-james.morse@arm.com>
 <20180921221705.6478-7-james.morse@arm.com> <20181012095702.GC12328@zn.tnic>
From: James Morse <james.morse@arm.com>
Message-ID: <ac63b5c1-181e-b1a4-9ca7-7664a192be4e@arm.com>
Date: Fri, 12 Oct 2018 18:18:03 +0100
MIME-Version: 1.0
In-Reply-To: <20181012095702.GC12328@zn.tnic>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com

Hi Boris,

On 12/10/2018 10:57, Borislav Petkov wrote:
> On Fri, Sep 21, 2018 at 11:16:53PM +0100, James Morse wrote:
>> To split up APEIs in_nmi() path, we need any nmi-like callers to always
>> be in_nmi(). KVM shouldn't have to know about this, pull the RAS plumbing
>> out into a header file.
>>
>> Currently guest synchronous external aborts are claimed as RAS
>> notifications by handle_guest_sea(), which is hidden in the arch codes
>> mm/fault.c. 32bit gets a dummy declaration in system_misc.h.
>>
>> There is going to be more of this in the future if/when we support
>> the SError-based firmware-first notification mechanism and/or
>> kernel-first notifications for both synchronous external abort and
>> SError. Each of these will come with some Kconfig symbols and a
>> handful of header files.
>>
>> Create a header file for all this.
>>
>> This patch gives handle_guest_sea() a 'kvm_' prefix, and moves the
>> declarations to kvm_ras.h as preparation for a future patch that moves
>> the ACPI-specific RAS code out of mm/fault.c.

>> diff --git a/arch/arm/include/asm/kvm_ras.h b/arch/arm/include/asm/kvm_ras.h
>> new file mode 100644
>> index 000000000000..aaff56bf338f
>> --- /dev/null
>> +++ b/arch/arm/include/asm/kvm_ras.h
>> @@ -0,0 +1,14 @@
>> +// SPDX-License-Identifier: GPL-2.0
>> +// Copyright (C) 2018 - Arm Ltd
> 
> checkpatch is complaining for some reason:
> 
> WARNING: Missing or malformed SPDX-License-Identifier tag in line 1
> #66: FILE: arch/arm/include/asm/kvm_ras.h:1:
> +// SPDX-License-Identifier: GPL-2.0

Gah, I copied it from a C file, the comment-style has to be different for headers.

Fixed,


Thanks

James
