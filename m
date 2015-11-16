Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 3593D6B025E
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 13:49:34 -0500 (EST)
Received: by wmww144 with SMTP id w144so123371006wmw.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 10:49:33 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id fz3si47745576wjb.198.2015.11.16.10.49.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Nov 2015 10:49:33 -0800 (PST)
Date: Mon, 16 Nov 2015 18:49:19 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH v2 05/12] arm64/efi: refactor EFI init and runtime code
 for reuse by 32-bit ARM
Message-ID: <20151116184919.GD8644@n2100.arm.linux.org.uk>
References: <1447698757-8762-1-git-send-email-ard.biesheuvel@linaro.org>
 <1447698757-8762-6-git-send-email-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1447698757-8762-6-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-efi@vger.kernel.org, matt.fleming@intel.com, will.deacon@arm.com, grant.likely@linaro.org, catalin.marinas@arm.com, mark.rutland@arm.com, leif.lindholm@linaro.org, roy.franz@linaro.org, msalter@redhat.com, ryan.harkin@linaro.org, akpm@linux-foundation.org, linux-mm@kvack.org

On Mon, Nov 16, 2015 at 07:32:30PM +0100, Ard Biesheuvel wrote:
> diff --git a/drivers/firmware/efi/arm-runtime.c b/drivers/firmware/efi/arm-runtime.c
> index e62ee5df96ca..ad11ba6964f6 100644
> --- a/drivers/firmware/efi/arm-runtime.c
> +++ b/drivers/firmware/efi/arm-runtime.c
> @@ -23,18 +23,15 @@
>  
>  #include <asm/cacheflush.h>
>  #include <asm/efi.h>
> -#include <asm/tlbflush.h>
> -#include <asm/mmu_context.h>
> +#include <asm/io.h>

Shouldn't this be linux/io.h ?

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
