Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E77506B025E
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 07:32:35 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id g186so321043064pgc.2
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 04:32:35 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g2si47925889plj.83.2016.12.13.04.32.35
        for <linux-mm@kvack.org>;
        Tue, 13 Dec 2016 04:32:35 -0800 (PST)
Date: Tue, 13 Dec 2016 12:31:44 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCHv5 09/11] mm/kasan: Switch to using __pa_symbol and
 lm_alias
Message-ID: <20161213123144.GB24607@leverpostej>
References: <1481068257-6367-1-git-send-email-labbott@redhat.com>
 <1481068257-6367-10-git-send-email-labbott@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1481068257-6367-10-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com

On Tue, Dec 06, 2016 at 03:50:55PM -0800, Laura Abbott wrote:
> 
> __pa_symbol is the correct API to find the physical address of symbols.
> Switch to it to allow for debugging APIs to work correctly. Other
> functions such as p*d_populate may call __pa internally. Ensure that the
> address passed is in the linear region by calling lm_alias.
> 
> Reviewed-by: Mark Rutland <mark.rutland@arm.com>
> Tested-by: Mark Rutland <mark.rutland@arm.com>
> Signed-off-by: Laura Abbott <labbott@redhat.com>
> ---
> v5: Add missing lm_alias call
> ---
>  mm/kasan/kasan_init.c | 15 ++++++++-------
>  1 file changed, 8 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/kasan/kasan_init.c b/mm/kasan/kasan_init.c
> index 3f9a41c..922f459 100644
> --- a/mm/kasan/kasan_init.c
> +++ b/mm/kasan/kasan_init.c
> @@ -16,6 +16,7 @@
>  #include <linux/kernel.h>
>  #include <linux/memblock.h>
>  #include <linux/pfn.h>
> +#include <linux/mm.h>

Nit: include ordering.

Regardless, my tags above still stand!

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
