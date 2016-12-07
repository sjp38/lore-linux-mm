Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D84C56B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 08:58:29 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id y68so602262781pfb.6
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 05:58:29 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 7si24143808pga.274.2016.12.07.05.58.28
        for <linux-mm@kvack.org>;
        Wed, 07 Dec 2016 05:58:29 -0800 (PST)
Date: Wed, 7 Dec 2016 13:57:40 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCHv4 09/10] mm/usercopy: Switch to using lm_alias
Message-ID: <20161207135740.GB25605@leverpostej>
References: <1480445729-27130-1-git-send-email-labbott@redhat.com>
 <1480445729-27130-10-git-send-email-labbott@redhat.com>
 <CAGXu5jKrBc6R9JYay1L6pd958Vm5-6p=37tiUYgg6uPeZb1HtQ@mail.gmail.com>
 <20161206181859.GH24177@leverpostej>
 <CAGXu5jKTdZUbbHU91mbN+Qy80AGXRhpzdLNXr3oxxZyxAzmjmQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jKTdZUbbHU91mbN+Qy80AGXRhpzdLNXr3oxxZyxAzmjmQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Laura Abbott <labbott@redhat.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Tue, Dec 06, 2016 at 12:10:50PM -0800, Kees Cook wrote:
> On Tue, Dec 6, 2016 at 10:18 AM, Mark Rutland <mark.rutland@arm.com> wrote:
> > On Tue, Nov 29, 2016 at 11:39:44AM -0800, Kees Cook wrote:
> >> On Tue, Nov 29, 2016 at 10:55 AM, Laura Abbott <labbott@redhat.com> wrote:
> >> >
> >> > The usercopy checking code currently calls __va(__pa(...)) to check for
> >> > aliases on symbols. Switch to using lm_alias instead.
> >> >
> >> > Signed-off-by: Laura Abbott <labbott@redhat.com>
> >>
> >> Acked-by: Kees Cook <keescook@chromium.org>
> >>
> >> I should probably add a corresponding alias test to lkdtm...
> >>
> >> -Kees
> >
> > Something like the below?
> >
> > It uses lm_alias(), so it depends on Laura's patches. We seem to do the
> > right thing, anyhow:
> 
> Cool, this looks good. What happens on systems without an alias?

In that case, lm_alias() should be an identity function, and we'll just
hit the usual kernel address (i.e. it should be identical to
USERCOPY_KERNEL).

> Laura, feel free to add this to your series:
> 
> Acked-by: Kees Cook <keescook@chromium.org>

I'm happy with that, or I can resend this as a proper patch once the
rest is in.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
