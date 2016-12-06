Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 219CD6B0069
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 13:59:13 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id y71so36056624pgd.0
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 10:59:13 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m87si20500404pfi.148.2016.12.06.10.59.12
        for <linux-mm@kvack.org>;
        Tue, 06 Dec 2016 10:59:12 -0800 (PST)
Date: Tue, 6 Dec 2016 18:58:24 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCHv4 10/10] arm64: Add support for CONFIG_DEBUG_VIRTUAL
Message-ID: <20161206185823.GJ24177@leverpostej>
References: <1480445729-27130-1-git-send-email-labbott@redhat.com>
 <1480445729-27130-11-git-send-email-labbott@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1480445729-27130-11-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org

On Tue, Nov 29, 2016 at 10:55:29AM -0800, Laura Abbott wrote:
> 
> +	WARN(!__is_lm_address(x),
> +	     "virt_to_phys used for non-linear address :%pK\n", (void *)x);

Nit: s/ :/: /

It might be worth adding %pS too; i.e.

	WARN(!__is_lm_address(x),
	     "virt_to_phys used for non-linear address: %pK (%pS)\n",
	     (void *)x, (void *)x);

... that way we might get a better idea before we have to resort to
grepping objdump output.

Other than that this looks good to me. This builds cleanly with and
without DEBUG_VIRTUAL enabled, and boots happily with DEBUG_VIRTUAL
disabled.

With both DEBUG_VIRTUAL and KASAN, I'm hitting a sea of warnings from
kasan_init at boot time, but I don't think that's a problem with this
patch as such, so FWIW:

Reviewed-by: Mark Rutland <mark.rutland@arm.com>
Tested-by: Mark Rutland <mark.rutland@arm.com>

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
