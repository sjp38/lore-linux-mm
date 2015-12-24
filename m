Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id EFED482F99
	for <linux-mm@kvack.org>; Wed, 23 Dec 2015 19:11:26 -0500 (EST)
Received: by mail-oi0-f46.google.com with SMTP id o124so131416195oia.1
        for <linux-mm@kvack.org>; Wed, 23 Dec 2015 16:11:26 -0800 (PST)
Received: from muru.com (muru.com. [72.249.23.125])
        by mx.google.com with ESMTP id o131si31703477oih.119.2015.12.23.16.11.26
        for <linux-mm@kvack.org>;
        Wed, 23 Dec 2015 16:11:26 -0800 (PST)
Date: Wed, 23 Dec 2015 16:11:22 -0800
From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH v2] ARM: mm: flip priority of CONFIG_DEBUG_RODATA
Message-ID: <20151224001121.GS2793@atomide.com>
References: <20151202202725.GA794@www.outflux.net>
 <20151223195129.GP2793@atomide.com>
 <567B04AB.6010906@redhat.com>
 <20151223212911.GR2793@atomide.com>
 <alpine.LFD.2.20.1512231637110.3603@knanqh.ubzr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.20.1512231637110.3603@knanqh.ubzr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Cc: Laura Abbott <labbott@redhat.com>, Kees Cook <keescook@chromium.org>, Russell King <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, kernel-hardening@lists.openwall.com, linux-arm-kernel@lists.infradead.org, Laura Abbott <labbott@fedoraproject.org>

* Nicolas Pitre <nicolas.pitre@linaro.org> [151223 13:45]:
> On Wed, 23 Dec 2015, Tony Lindgren wrote:
> 
> > Hi,
> > 
> > * Laura Abbott <labbott@redhat.com> [151223 12:31]:
> > > 
> > > Looks like a case similar to Geert's
> > > 
> > >         adr     r7, kick_counter
> > > wait_dll_lock_timed:
> > >         ldr     r4, wait_dll_lock_counter
> > >         add     r4, r4, #1
> > >         str     r4, [r7, #wait_dll_lock_counter - kick_counter]
> > >         ldr     r4, sdrc_dlla_status
> > >         /* Wait 20uS for lock */
> > >         mov     r6, #8
> > > 
> > > 
> > > kick_counter and wait_dll_lock_counter are in the text section which is marked read only.
> > > They need to be moved to the data section along with a few other variables from what I
> > > can tell (maybe those are read only?).
> > 
> > Thanks for looking, yeah so it seem.
> > 
> > > I suspect this is going to be a common issue with suspend/resume code paths since those
> > > are hand written assembly.
> > 
> > Yes I suspect we have quite a few cases like this.
> 
> We fixed a bunch of similar issues where code was located in the .data 
> section for ease of use from assembly code.  See commit b4e61537 and 
> d0776aff for example.

Thanks hey some assembly fun for the holidays :) I also need to check what
all gets relocated to SRAM here.

In any case, seems like the $subject patch is too intrusive for v4.5 at
this point.

Regards,

Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
