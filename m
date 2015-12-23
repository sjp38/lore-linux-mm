Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id E9DB082F64
	for <linux-mm@kvack.org>; Wed, 23 Dec 2015 16:29:16 -0500 (EST)
Received: by mail-ob0-f177.google.com with SMTP id bx1so56131446obb.0
        for <linux-mm@kvack.org>; Wed, 23 Dec 2015 13:29:16 -0800 (PST)
Received: from muru.com (muru.com. [72.249.23.125])
        by mx.google.com with ESMTP id m4si5534896oes.28.2015.12.23.13.29.16
        for <linux-mm@kvack.org>;
        Wed, 23 Dec 2015 13:29:16 -0800 (PST)
Date: Wed, 23 Dec 2015 13:29:12 -0800
From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH v2] ARM: mm: flip priority of CONFIG_DEBUG_RODATA
Message-ID: <20151223212911.GR2793@atomide.com>
References: <20151202202725.GA794@www.outflux.net>
 <20151223195129.GP2793@atomide.com>
 <567B04AB.6010906@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <567B04AB.6010906@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Kees Cook <keescook@chromium.org>, Russell King <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Nicolas Pitre <nico@linaro.org>, Will Deacon <will.deacon@arm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, kernel-hardening@lists.openwall.com, linux-arm-kernel@lists.infradead.org, Laura Abbott <labbott@fedoraproject.org>

Hi,

* Laura Abbott <labbott@redhat.com> [151223 12:31]:
> 
> Looks like a case similar to Geert's
> 
>         adr     r7, kick_counter
> wait_dll_lock_timed:
>         ldr     r4, wait_dll_lock_counter
>         add     r4, r4, #1
>         str     r4, [r7, #wait_dll_lock_counter - kick_counter]
>         ldr     r4, sdrc_dlla_status
>         /* Wait 20uS for lock */
>         mov     r6, #8
> 
> 
> kick_counter and wait_dll_lock_counter are in the text section which is marked read only.
> They need to be moved to the data section along with a few other variables from what I
> can tell (maybe those are read only?).

Thanks for looking, yeah so it seem.

> I suspect this is going to be a common issue with suspend/resume code paths since those
> are hand written assembly.

Yes I suspect we have quite a few cases like this.

Regards,

Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
