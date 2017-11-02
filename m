Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id CF69E6B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 14:57:35 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id m81so1161196ioi.3
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 11:57:35 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f185sor165443ith.53.2017.11.02.11.57.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 Nov 2017 11:57:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1711021938420.2824@nanos>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <20171031223150.AB41C68F@viggo.jf.intel.com>
 <alpine.DEB.2.20.1711012206050.1942@nanos> <CALCETrWQ0W=Kp7fycZ2E9Dp84CCPOr1nEmsPom71ZAXeRYqr9g@mail.gmail.com>
 <alpine.DEB.2.20.1711012225400.1942@nanos> <e8149c9e-10f8-aa74-ff0e-e2de923b2128@linux.intel.com>
 <CA+55aFyijHb4WnDMKgeXekTZHYT8pajqSAu2peo3O4EKiZbYPA@mail.gmail.com>
 <alpine.DEB.2.20.1711012316130.1942@nanos> <CALCETrWS2Tqn=hthSnzxKj3tJrgK+HH2Nkdv-GiXA7bkHUBdcQ@mail.gmail.com>
 <alpine.DEB.2.20.1711021226020.2090@nanos> <c4a5395b-5869-d088-9819-8457d138dc43@linux.intel.com>
 <DADF7172-F2ED-4C2A-B921-8707DEDEABD7@amacapital.net> <CA+55aFxEsMddbGhPWTQ_gDW7p-H_gxGFGz7q8LrNUxF5ChN+jg@mail.gmail.com>
 <alpine.DEB.2.20.1711021938420.2824@nanos>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 2 Nov 2017 11:57:33 -0700
Message-ID: <CA+55aFycL4Opz3gg6s_Sqtwcdp1yqAWQNP1tLheES8=Vw7ynwQ@mail.gmail.com>
Subject: Re: [PATCH 02/23] x86, kaiser: do not set _PAGE_USER for init_mm page tables
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@amacapital.net>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On Thu, Nov 2, 2017 at 11:40 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
>
> Hmm. Not sure. IIRC you need to be able to read it to figure out where the
> entry points are. They are at fixed offsets, but there is some voodoo out
> there which reads the 'elf' to get to them.

That would actually be really painful.

But I *think* you're confusing it with the vdso case, which really
does do that whole "generate ELF information for debuggers and dynamic
linkers" thing. The vsyscall page never did that afaik, and purely
relied on fixed addresses.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
