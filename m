Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 284D06B02F5
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 05:55:03 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id b189so179236wmd.5
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 02:55:03 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l20sor3815555wmh.82.2017.11.28.02.55.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Nov 2017 02:55:02 -0800 (PST)
Date: Tue, 28 Nov 2017 11:54:58 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] vfs: Add PERM_* symbolic helpers for common file
 mode/permissions
Message-ID: <20171128105458.7pxbt2kabb5po5ho@gmail.com>
References: <20171126231403.657575796@linutronix.de>
 <20171126232414.563046145@linutronix.de>
 <20171127094156.rbq7i7it7ojsblfj@hirez.programming.kicks-ass.net>
 <20171127100635.kfw2nspspqbrf2qm@gmail.com>
 <CA+55aFyLC9+S=MZueRXMmwwnx47bhovXr1YhRg+FAPFfQZXoYA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyLC9+S=MZueRXMmwwnx47bhovXr1YhRg+FAPFfQZXoYA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Rik van Riel <riel@redhat.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, linux-mm <linux-mm@kvack.org>, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Mon, Nov 27, 2017 at 2:06 AM, Ingo Molnar <mingo@kernel.org> wrote:
> >
> >
> > +/*
> > + * Human readable symbolic definitions for common
> > + * file permissions:
> > + */
> > +#define PERM_r________ 0400
> > +#define PERM_r__r_____ 0440
> > +#define PERM_r__r__r__ 0444
> 
> I'm not a fan. Particularly as you have a very random set of
> permissions (rx and wx? Not very common), but also because it's just
> not that legible.
> 
> I've argued several times that we shouldn't use the defines at all.
> The octal format isn't any less legible than any #define I've ever
> seen, and is generally _more_ legible.
> 
> What's wrong with just using 0400 for "read by user"?

Yeah, the octal format isn't all that bad - at least relative to the symbolic 
obfuscation defines.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
