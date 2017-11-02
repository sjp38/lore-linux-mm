Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 029976B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 14:40:33 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r196so120637wmf.3
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 11:40:32 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id y8si241310wmd.129.2017.11.02.11.40.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 02 Nov 2017 11:40:31 -0700 (PDT)
Date: Thu, 2 Nov 2017 19:40:27 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 02/23] x86, kaiser: do not set _PAGE_USER for init_mm
 page tables
In-Reply-To: <CA+55aFxEsMddbGhPWTQ_gDW7p-H_gxGFGz7q8LrNUxF5ChN+jg@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1711021938420.2824@nanos>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <20171031223150.AB41C68F@viggo.jf.intel.com> <alpine.DEB.2.20.1711012206050.1942@nanos> <CALCETrWQ0W=Kp7fycZ2E9Dp84CCPOr1nEmsPom71ZAXeRYqr9g@mail.gmail.com> <alpine.DEB.2.20.1711012225400.1942@nanos>
 <e8149c9e-10f8-aa74-ff0e-e2de923b2128@linux.intel.com> <CA+55aFyijHb4WnDMKgeXekTZHYT8pajqSAu2peo3O4EKiZbYPA@mail.gmail.com> <alpine.DEB.2.20.1711012316130.1942@nanos> <CALCETrWS2Tqn=hthSnzxKj3tJrgK+HH2Nkdv-GiXA7bkHUBdcQ@mail.gmail.com>
 <alpine.DEB.2.20.1711021226020.2090@nanos> <c4a5395b-5869-d088-9819-8457d138dc43@linux.intel.com> <DADF7172-F2ED-4C2A-B921-8707DEDEABD7@amacapital.net> <CA+55aFxEsMddbGhPWTQ_gDW7p-H_gxGFGz7q8LrNUxF5ChN+jg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On Thu, 2 Nov 2017, Linus Torvalds wrote:

> On Thu, Nov 2, 2017 at 11:19 AM, Andy Lutomirski <luto@amacapital.net> wrote:
> >
> > We'd have to force NONE, and Linus won't like it.
> 
> Oh, I think it's fine for the kaiser case.
> 
> I am not convinced anybody will actually use it, but if you do use it,
> I suspect "the legacy vsyscall page no longer works" is the least of
> your worries.
> 
> That said, I think you can keep emulation, and just make it
> unreadable. That will keep legacy binaries still working, and will
> break a much smaller subset. So we have four cases:
> 
>  - native
>  - read-only emulation
>  - unreadable emulation
>  - none
> 
> and kaiser triggering that unreadable case sounds like the option
> least likely to cause trouble. vsyscalls still work, anybody who tries
> to trace them and look at the code will not.

Hmm. Not sure. IIRC you need to be able to read it to figure out where the
entry points are. They are at fixed offsets, but there is some voodoo out
there which reads the 'elf' to get to them.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
