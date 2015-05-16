Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id B8FC66B0032
	for <linux-mm@kvack.org>; Sat, 16 May 2015 07:27:47 -0400 (EDT)
Received: by wicnf17 with SMTP id nf17so19538272wic.1
        for <linux-mm@kvack.org>; Sat, 16 May 2015 04:27:47 -0700 (PDT)
Received: from lb3-smtp-cloud6.xs4all.net (lb3-smtp-cloud6.xs4all.net. [194.109.24.31])
        by mx.google.com with ESMTPS id do5si2585044wib.50.2015.05.16.04.27.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 16 May 2015 04:27:46 -0700 (PDT)
Message-ID: <1431775656.2341.10.camel@x220>
Subject: Re: [PATCH v2 1/5] kasan, x86: move KASAN_SHADOW_OFFSET to the arch
 Kconfig
From: Paul Bolle <pebolle@tiscali.nl>
Date: Sat, 16 May 2015 13:27:36 +0200
In-Reply-To: <1431698344-28054-2-git-send-email-a.ryabinin@samsung.com>
References: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
	 <1431698344-28054-2-git-send-email-a.ryabinin@samsung.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, David Keitel <dkeitel@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, "maintainer:X86
 ARCHITECTURE..." <x86@kernel.org>

On Fri, 2015-05-15 at 16:59 +0300, Andrey Ryabinin wrote:
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig

> +config KASAN_SHADOW_OFFSET
> +	hex
> +	default 0xdffffc0000000000

This sets CONFIG_KASAN_SHADOW_OFFSET for _all_ X86 configurations,
doesn't it?

> --- a/lib/Kconfig.kasan
> +++ b/lib/Kconfig.kasan
 
> -config KASAN_SHADOW_OFFSET
> -	hex
> -	default 0xdffffc0000000000 if X86_64

While here it used to depend, at least, on HAVE_ARCH_KASAN. But grepping
the tree shows the two places where CONFIG_KASAN_SHADOW_OFFSET is
currently used are guarded by #ifdef CONFIG_KASAN. So perhaps the
default line should actually read
	default 0xdffffc0000000000 if KASAN

after the move. Would that work?


Paul Bolle

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
