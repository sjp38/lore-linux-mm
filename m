Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 091606B0253
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 14:21:30 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id x63so36086333ioe.18
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 11:21:30 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i81sor2096703iof.237.2017.11.27.11.21.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 11:21:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171127100635.kfw2nspspqbrf2qm@gmail.com>
References: <20171126231403.657575796@linutronix.de> <20171126232414.563046145@linutronix.de>
 <20171127094156.rbq7i7it7ojsblfj@hirez.programming.kicks-ass.net> <20171127100635.kfw2nspspqbrf2qm@gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 27 Nov 2017 11:21:28 -0800
Message-ID: <CA+55aFyLC9+S=MZueRXMmwwnx47bhovXr1YhRg+FAPFfQZXoYA@mail.gmail.com>
Subject: Re: [PATCH] vfs: Add PERM_* symbolic helpers for common file mode/permissions
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Rik van Riel <riel@redhat.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, linux-mm <linux-mm@kvack.org>, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

On Mon, Nov 27, 2017 at 2:06 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
>
> +/*
> + * Human readable symbolic definitions for common
> + * file permissions:
> + */
> +#define PERM_r________ 0400
> +#define PERM_r__r_____ 0440
> +#define PERM_r__r__r__ 0444

I'm not a fan. Particularly as you have a very random set of
permissions (rx and wx? Not very common), but also because it's just
not that legible.

I've argued several times that we shouldn't use the defines at all.
The octal format isn't any less legible than any #define I've ever
seen, and is generally _more_ legible.

What's wrong with just using 0400 for "read by user"?

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
