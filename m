Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id DD7096B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 08:19:16 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id c82so4504182wme.8
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 05:19:16 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 93si21987493wrs.362.2017.11.27.05.19.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 27 Nov 2017 05:19:15 -0800 (PST)
Date: Mon, 27 Nov 2017 14:18:44 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [patch V2 1/5] x86/kaiser: Respect disabled CPU features
In-Reply-To: <CAMzpN2joDWU41SpNTu30pnOsZbdNcDMiCZ99HBy53SFVwvxMuw@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1711271416410.1799@nanos>
References: <20171126231403.657575796@linutronix.de> <20171126232414.313869499@linutronix.de> <20171127095737.ocolhqaxsaboycwa@hirez.programming.kicks-ass.net> <alpine.DEB.2.20.1711271241100.1799@nanos>
 <CAMzpN2joDWU41SpNTu30pnOsZbdNcDMiCZ99HBy53SFVwvxMuw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Gerst <brgerst@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Linux-MM <linux-mm@kvack.org>, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

On Mon, 27 Nov 2017, Brian Gerst wrote:
> On Mon, Nov 27, 2017 at 6:47 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> > On Mon, 27 Nov 2017, Peter Zijlstra wrote:
> >> On Mon, Nov 27, 2017 at 12:14:04AM +0100, Thomas Gleixner wrote:
> >> > PAGE_NX and PAGE_GLOBAL might be not supported or disabled on the command
> >> > line, but KAISER sets them unconditionally.
> >>
> >> So KAISER is x86_64 only, right? AFAIK there is no x86_64 without NX
> >> support. So would it not make sense to mandate NX for KAISER?, that is
> >> instead of making "noexec" + KAISER work, make "noexec" kill KAISER +
> >> emit a warning.
> >
> > OTOH, disabling NX is a simple way to verify that DEBUG_WX works correctly
> > also on the shadow maps.
> >
> > But surely we can drop the PAGE_GLOBAL thing, as all 64bit systems have it.
> 
> I seem to recall that some virtualized environments (maybe Xen?) don't
> support global pages.

Uuurg. Ok, we leave it as is for now. Better safe than sorry. It does no
harm.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
