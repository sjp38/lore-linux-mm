Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D42336B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 08:56:42 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id y7so2833358wmd.18
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 05:56:42 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id o40si2638943wrf.300.2017.11.02.05.56.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 02 Nov 2017 05:56:41 -0700 (PDT)
Date: Thu, 2 Nov 2017 13:56:38 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 02/23] x86, kaiser: do not set _PAGE_USER for init_mm
 page tables
In-Reply-To: <A4F58550-CAA8-4AE2-8DE5-C6970CC47210@amacapital.net>
Message-ID: <alpine.DEB.2.20.1711021345550.2090@nanos>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <20171031223150.AB41C68F@viggo.jf.intel.com> <alpine.DEB.2.20.1711012206050.1942@nanos> <CALCETrWQ0W=Kp7fycZ2E9Dp84CCPOr1nEmsPom71ZAXeRYqr9g@mail.gmail.com> <alpine.DEB.2.20.1711012225400.1942@nanos>
 <e8149c9e-10f8-aa74-ff0e-e2de923b2128@linux.intel.com> <CA+55aFyijHb4WnDMKgeXekTZHYT8pajqSAu2peo3O4EKiZbYPA@mail.gmail.com> <alpine.DEB.2.20.1711012316130.1942@nanos> <CALCETrWS2Tqn=hthSnzxKj3tJrgK+HH2Nkdv-GiXA7bkHUBdcQ@mail.gmail.com>
 <alpine.DEB.2.20.1711021226020.2090@nanos> <A4F58550-CAA8-4AE2-8DE5-C6970CC47210@amacapital.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andy Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On Thu, 2 Nov 2017, Andy Lutomirski wrote:
> > On Nov 2, 2017, at 12:33 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> > Fair enough. I enabled function tracing with emulate_vsyscall as the filter
> > on a couple of machines and so far I have no hit at all. Though I found a
> > VM with a real old user space (~2005) and that actually used it.
> > 
> > So for the problem at hand, I'd suggest we disable the vsyscall stuff if
> > CONFIG_KAISER=y and be done with it.
> 
> I think that time() on not-so-old glibc uses it.

Sigh.

> Even more recent versions of Go use it. :(

Groan. VDSO is there since 2007 and the first usable version of Go was
released in 2012.....

Thanks,

	tglx


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
