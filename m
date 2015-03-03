Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 3529F6B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 20:52:31 -0500 (EST)
Received: by pdno5 with SMTP id o5so44192337pdn.8
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 17:52:30 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id f6si1564695pdn.231.2015.03.02.17.52.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Mar 2015 17:52:28 -0800 (PST)
Message-ID: <54F513C0.4000706@infradead.org>
Date: Mon, 02 Mar 2015 17:52:00 -0800
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 1/4] mm: move memtest under /mm
References: <1425308145-20769-1-git-send-email-vladimir.murzin@arm.com> <1425308145-20769-2-git-send-email-vladimir.murzin@arm.com>
In-Reply-To: <1425308145-20769-2-git-send-email-vladimir.murzin@arm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Murzin <vladimir.murzin@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, linux-arm-kernel@lists.infradead.org
Cc: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, lauraa@codeaurora.org, catalin.marinas@arm.com, will.deacon@arm.com, linux@arm.linux.org.uk, arnd@arndb.de, mark.rutland@arm.com, ard.biesheuvel@linaro.org

On 03/02/15 06:55, Vladimir Murzin wrote:
> There is nothing platform dependent in the core memtest code, so other platform
> might benefit of this feature too.
> 
> Signed-off-by: Vladimir Murzin <vladimir.murzin@arm.com>
> ---
>  arch/x86/Kconfig            |   11 ----
>  arch/x86/include/asm/e820.h |    8 ---
>  arch/x86/mm/Makefile        |    2 -
>  arch/x86/mm/memtest.c       |  118 -------------------------------------------
>  include/linux/memblock.h    |    8 +++
>  lib/Kconfig.debug           |   11 ++++
>  mm/Makefile                 |    1 +
>  mm/memtest.c                |  118 +++++++++++++++++++++++++++++++++++++++++++
>  8 files changed, 138 insertions(+), 139 deletions(-)
>  delete mode 100644 arch/x86/mm/memtest.c
>  create mode 100644 mm/memtest.c

> diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
> index c5cefb3..8eb064fd 100644
> --- a/lib/Kconfig.debug
> +++ b/lib/Kconfig.debug
> @@ -1732,6 +1732,17 @@ config TEST_UDELAY
>  
>  	  If unsure, say N.
>  
> +config MEMTEST
> +	bool "Memtest"
> +	---help---
> +	  This option adds a kernel parameter 'memtest', which allows memtest
> +	  to be set.
> +	        memtest=0, mean disabled; -- default
> +	        memtest=1, mean do 1 test pattern;
> +	        ...
> +	        memtest=4, mean do 4 test patterns.

This sort of implies a max of 4 test patterns, but it seems to be 17
if I counted correctly, so if someone wants to test all of the possible
'memtest' patterns, they would need to use 'memtest=17', is that correct?


> +	  If you are unsure how to answer this question, answer N.

Thanks,
-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
