Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 79F9F6B0253
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 13:45:48 -0500 (EST)
Received: by wmvv187 with SMTP id v187so226933767wmv.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 10:45:48 -0800 (PST)
Received: from Galois.linutronix.de (linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id u185si6683687wmu.20.2015.12.08.10.45.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 08 Dec 2015 10:45:47 -0800 (PST)
Date: Tue, 8 Dec 2015 19:44:59 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 28/34] x86: wire up mprotect_key() system call
In-Reply-To: <20151204011503.2A095839@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.11.1512081943270.3595@nanos>
References: <20151204011424.8A36E365@viggo.jf.intel.com> <20151204011503.2A095839@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com, linux-api@vger.kernel.org

On Thu, 3 Dec 2015, Dave Hansen wrote:
>  #include <asm-generic/mman.h>
> diff -puN mm/Kconfig~pkeys-16-x86-mprotect_key mm/Kconfig
> --- a/mm/Kconfig~pkeys-16-x86-mprotect_key	2015-12-03 16:21:31.114920208 -0800
> +++ b/mm/Kconfig	2015-12-03 16:21:31.119920435 -0800
> @@ -679,4 +679,5 @@ config NR_PROTECTION_KEYS
>  	# Everything supports a _single_ key, so allow folks to
>  	# at least call APIs that take keys, but require that the
>  	# key be 0.
> +	default 16 if X86_INTEL_MEMORY_PROTECTION_KEYS
>  	default 1

What happens if I set that to 42?

I think we want to make this a runtime evaluated thingy. If pkeys are
compiled in, but the machine does not support it then we don't support
16 keys, or do we?

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
