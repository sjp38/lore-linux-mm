Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3A53F6B0253
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 07:32:16 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id j128so164166297pfg.4
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 04:32:16 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q63si47932594pfi.151.2016.12.13.04.32.15
        for <linux-mm@kvack.org>;
        Tue, 13 Dec 2016 04:32:15 -0800 (PST)
Date: Tue, 13 Dec 2016 12:31:22 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCHv5 06/11] arm64: Use __pa_symbol for kernel symbols
Message-ID: <20161213123122.GA24607@leverpostej>
References: <1481068257-6367-1-git-send-email-labbott@redhat.com>
 <1481068257-6367-7-git-send-email-labbott@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1481068257-6367-7-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org

On Tue, Dec 06, 2016 at 03:50:52PM -0800, Laura Abbott wrote:
> 
> __pa_symbol is technically the marcro that should be used for kernel
> symbols. Switch to this as a pre-requisite for DEBUG_VIRTUAL which
> will do bounds checking.
> 
> Tested-by: James Morse <james.morse@arm.com>
> Signed-off-by: Laura Abbott <labbott@redhat.com>

This looks good to me; I have a (very minor) nit below, but either way:

Reviewed-by: Mark Rutland <mark.rutland@arm.com>
Tested-by: Mark Rutland <mark.rutland@arm.com>

> diff --git a/arch/arm64/kernel/acpi_parking_protocol.c b/arch/arm64/kernel/acpi_parking_protocol.c
> index a32b401..ca880ce 100644
> --- a/arch/arm64/kernel/acpi_parking_protocol.c
> +++ b/arch/arm64/kernel/acpi_parking_protocol.c
> @@ -18,6 +18,7 @@
>   */
>  #include <linux/acpi.h>
>  #include <linux/types.h>
> +#include <linux/mm.h>

Nit: please keep includes alphabetically ordered, at least where they're
ordered today. Some files are already a mess, but it would be nice to
keep the well-ordered ones ordered.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
