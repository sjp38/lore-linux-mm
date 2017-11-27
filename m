Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id ABF686B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 07:31:39 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id w191so35015730iof.11
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 04:31:39 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l70sor6964980iol.152.2017.11.27.04.31.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 04:31:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1711271241100.1799@nanos>
References: <20171126231403.657575796@linutronix.de> <20171126232414.313869499@linutronix.de>
 <20171127095737.ocolhqaxsaboycwa@hirez.programming.kicks-ass.net> <alpine.DEB.2.20.1711271241100.1799@nanos>
From: Brian Gerst <brgerst@gmail.com>
Date: Mon, 27 Nov 2017 07:31:37 -0500
Message-ID: <CAMzpN2joDWU41SpNTu30pnOsZbdNcDMiCZ99HBy53SFVwvxMuw@mail.gmail.com>
Subject: Re: [patch V2 1/5] x86/kaiser: Respect disabled CPU features
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Linux-MM <linux-mm@kvack.org>, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

On Mon, Nov 27, 2017 at 6:47 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> On Mon, 27 Nov 2017, Peter Zijlstra wrote:
>> On Mon, Nov 27, 2017 at 12:14:04AM +0100, Thomas Gleixner wrote:
>> > PAGE_NX and PAGE_GLOBAL might be not supported or disabled on the command
>> > line, but KAISER sets them unconditionally.
>>
>> So KAISER is x86_64 only, right? AFAIK there is no x86_64 without NX
>> support. So would it not make sense to mandate NX for KAISER?, that is
>> instead of making "noexec" + KAISER work, make "noexec" kill KAISER +
>> emit a warning.
>
> OTOH, disabling NX is a simple way to verify that DEBUG_WX works correctly
> also on the shadow maps.
>
> But surely we can drop the PAGE_GLOBAL thing, as all 64bit systems have it.

I seem to recall that some virtualized environments (maybe Xen?) don't
support global pages.

--
Brian Gerst

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
