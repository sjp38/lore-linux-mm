Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3D6836B74A8
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 09:00:41 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id t13so9432108otk.4
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 06:00:41 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t13si8696252oic.30.2018.12.05.06.00.40
        for <linux-mm@kvack.org>;
        Wed, 05 Dec 2018 06:00:40 -0800 (PST)
Subject: Re: [PATCH RFC 6/7] arm64: kexec: no need to ClearPageReserved()
References: <20181205122851.5891-1-david@redhat.com>
 <20181205122851.5891-7-david@redhat.com>
From: James Morse <james.morse@arm.com>
Message-ID: <ce6a4c28-3c3b-329e-df01-325294bd9b2e@arm.com>
Date: Wed, 5 Dec 2018 14:00:35 +0000
MIME-Version: 1.0
In-Reply-To: <20181205122851.5891-7-david@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-m68k@lists.linux-m68k.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-mediatek@lists.infradead.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Bhupesh Sharma <bhsharma@redhat.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Kleikamp <dave.kleikamp@oracle.com>, Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>, AKASHI Takahiro <takahiro.akashi@linaro.org>

Hi David,

(CC: +Akashi)

On 05/12/2018 12:28, David Hildenbrand wrote:
> This will already be done by free_reserved_page().

(will already be -> will be ?)

So it does!


> diff --git a/arch/arm64/kernel/machine_kexec.c b/arch/arm64/kernel/machine_kexec.c
> index 922add8adb74..0ef4ea73aa54 100644
> --- a/arch/arm64/kernel/machine_kexec.c
> +++ b/arch/arm64/kernel/machine_kexec.c
> @@ -353,7 +353,6 @@ void crash_free_reserved_phys_range(unsigned long begin, unsigned long end)
>  
>  	for (addr = begin; addr < end; addr += PAGE_SIZE) {
>  		page = phys_to_page(addr);
> -		ClearPageReserved(page);
>  		free_reserved_page(page);
>  	}
>  }
> 

Acked-by: James Morse <james.morse@arm.com>


Thanks,

James
