Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id A45816B0022
	for <linux-mm@kvack.org>; Mon,  2 Apr 2018 14:20:18 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id q185so11164482qke.0
        for <linux-mm@kvack.org>; Mon, 02 Apr 2018 11:20:18 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a12sor704877qta.28.2018.04.02.11.20.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Apr 2018 11:20:17 -0700 (PDT)
Date: Mon, 2 Apr 2018 14:20:15 -0400 (EDT)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH v3 5/6] Initialize the mapping of KASan shadow memory
In-Reply-To: <20180402181536.GJ16141@n2100.armlinux.org.uk>
Message-ID: <nycvar.YSQ.7.76.1804021418220.28462@knanqh.ubzr>
References: <20180402120440.31900-1-liuwenliang@huawei.com> <20180402120440.31900-6-liuwenliang@huawei.com> <nycvar.YSQ.7.76.1804021402521.28462@knanqh.ubzr> <20180402181536.GJ16141@n2100.armlinux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Cc: Abbott Liu <liuwenliang@huawei.com>, kstewart@linuxfoundation.org, tixy@linaro.org, grygorii.strashko@linaro.org, julien.thierry@arm.com, Catalin Marinas <catalin.marinas@arm.com>, linux@rasmusvillemoes.dk, dhowells@redhat.com, linux-mm@kvack.org, mark.rutland@arm.com, kvmarm@lists.cs.columbia.edu, f.fainelli@gmail.com, Jonathan Corbet <corbet@lwn.net>, linux-doc@vger.kernel.org, kasan-dev@googlegroups.com, geert@linux-m68k.org, linux-arm-kernel@lists.infradead.org, zhichao.huang@linaro.org, aryabinin@virtuozzo.com, labbott@redhat.com, vladimir.murzin@arm.com, keescook@chromium.org, Arnd Bergmann <arnd@arndb.de>, marc.zyngier@arm.com, philip@cog.systems, jinb.park7@gmail.com, opendmb@gmail.com, tglx@linutronix.de, dvyukov@google.com, ard.biesheuvel@linaro.org, gregkh@linuxfoundation.org, mawilcox@microsoft.com, linux-kernel@vger.kernel.org, alexander.levin@verizon.com, james.morse@arm.com, kirill.shutemov@linux.intel.com, pombredanne@nexb.com, Andrew Morton <akpm@linux-foundation.org>, thgarnie@google.com, christoffer.dall@linaro.org

On Mon, 2 Apr 2018, Russell King - ARM Linux wrote:

> On Mon, Apr 02, 2018 at 02:08:13PM -0400, Nicolas Pitre wrote:
> > On Mon, 2 Apr 2018, Abbott Liu wrote:
> > 
> > > index c79b829..20161e2 100644
> > > --- a/arch/arm/kernel/head-common.S
> > > +++ b/arch/arm/kernel/head-common.S
> > > @@ -115,6 +115,9 @@ __mmap_switched:
> > >  	str	r8, [r2]			@ Save atags pointer
> > >  	cmp	r3, #0
> > >  	strne	r10, [r3]			@ Save control register values
> > > +#ifdef CONFIG_KASAN
> > > +	bl	kasan_early_init
> > > +#endif
> > >  	mov	lr, #0
> > >  	b	start_kernel
> > >  ENDPROC(__mmap_switched)
> > 
> > Would be better if lr was cleared before calling kasan_early_init.
> 
> No.  The code is correct - please remember that "bl" writes to LR.

You're right of course.

/me giving up on patch review and going back to bed


Nicolas
