Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id AC8026B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 14:24:38 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z96so228288wrb.21
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 11:24:38 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id g65si204789wma.253.2017.11.02.11.24.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 02 Nov 2017 11:24:37 -0700 (PDT)
Date: Thu, 2 Nov 2017 19:24:32 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 02/23] x86, kaiser: do not set _PAGE_USER for init_mm
 page tables
In-Reply-To: <DADF7172-F2ED-4C2A-B921-8707DEDEABD7@amacapital.net>
Message-ID: <alpine.DEB.2.20.1711021923020.2824@nanos>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <20171031223150.AB41C68F@viggo.jf.intel.com> <alpine.DEB.2.20.1711012206050.1942@nanos> <CALCETrWQ0W=Kp7fycZ2E9Dp84CCPOr1nEmsPom71ZAXeRYqr9g@mail.gmail.com> <alpine.DEB.2.20.1711012225400.1942@nanos>
 <e8149c9e-10f8-aa74-ff0e-e2de923b2128@linux.intel.com> <CA+55aFyijHb4WnDMKgeXekTZHYT8pajqSAu2peo3O4EKiZbYPA@mail.gmail.com> <alpine.DEB.2.20.1711012316130.1942@nanos> <CALCETrWS2Tqn=hthSnzxKj3tJrgK+HH2Nkdv-GiXA7bkHUBdcQ@mail.gmail.com>
 <alpine.DEB.2.20.1711021226020.2090@nanos> <c4a5395b-5869-d088-9819-8457d138dc43@linux.intel.com> <DADF7172-F2ED-4C2A-B921-8707DEDEABD7@amacapital.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On Thu, 2 Nov 2017, Andy Lutomirski wrote:

> > On Nov 2, 2017, at 5:38 PM, Dave Hansen <dave.hansen@linux.intel.com> wrote:
> > 
> >> On 11/02/2017 04:33 AM, Thomas Gleixner wrote:
> >> So for the problem at hand, I'd suggest we disable the vsyscall stuff if
> >> CONFIG_KAISER=y and be done with it.
> > 
> > Just to be clear, are we suggesting to just disable
> > LEGACY_VSYSCALL_NATIVE if KAISER=y, and allow LEGACY_VSYSCALL_EMULATE?
> > Or, do we just force LEGACY_VSYSCALL_NONE=y?
> 
> We'd have to force NONE, and Linus won't like it.

The much I hate it, I already accepted grudgingly that we have to keep it
alive in some way or the other.

Thanks,

	tglx


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
