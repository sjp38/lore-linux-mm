Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id EBFF36B0257
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 10:24:45 -0400 (EDT)
Received: by igvi1 with SMTP id i1so130217796igv.1
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 07:24:45 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id zx8si13183002igc.15.2015.07.22.07.24.45
        for <linux-mm@kvack.org>;
        Wed, 22 Jul 2015 07:24:45 -0700 (PDT)
Date: Wed, 22 Jul 2015 15:24:40 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v3 5/5] ARM64: kasan: print memory assignment
Message-ID: <20150722142440.GD16627@e104818-lin.cambridge.arm.com>
References: <1437561037-31995-1-git-send-email-a.ryabinin@samsung.com>
 <1437561037-31995-6-git-send-email-a.ryabinin@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437561037-31995-6-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Linus Walleij <linus.walleij@linaro.org>, linux-kernel@vger.kernel.org, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>

On Wed, Jul 22, 2015 at 01:30:37PM +0300, Andrey Ryabinin wrote:
> From: Linus Walleij <linus.walleij@linaro.org>
> 
> This prints out the virtual memory assigned to KASan in the
> boot crawl along with other memory assignments, if and only
> if KASan is activated.
> 
> Example dmesg from the Juno Development board:
> 
> Memory: 1691156K/2080768K available (5465K kernel code, 444K rwdata,
> 2160K rodata, 340K init, 217K bss, 373228K reserved, 16384K cma-reserved)
> Virtual kernel memory layout:
>     kasan   : 0xffffff8000000000 - 0xffffff9000000000   (    64 GB)
>     vmalloc : 0xffffff9000000000 - 0xffffffbdbfff0000   (   182 GB)
>     vmemmap : 0xffffffbdc0000000 - 0xffffffbfc0000000   (     8 GB maximum)
>               0xffffffbdc2000000 - 0xffffffbdc3fc0000   (    31 MB actual)
>     fixed   : 0xffffffbffabfd000 - 0xffffffbffac00000   (    12 KB)
>     PCI I/O : 0xffffffbffae00000 - 0xffffffbffbe00000   (    16 MB)
>     modules : 0xffffffbffc000000 - 0xffffffc000000000   (    64 MB)
>     memory  : 0xffffffc000000000 - 0xffffffc07f000000   (  2032 MB)
>       .init : 0xffffffc0007f5000 - 0xffffffc00084a000   (   340 KB)
>       .text : 0xffffffc000080000 - 0xffffffc0007f45b4   (  7634 KB)
>       .data : 0xffffffc000850000 - 0xffffffc0008bf200   (   445 KB)
> 
> Signed-off-by: Linus Walleij <linus.walleij@linaro.org>
> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
