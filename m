Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 294A56B0038
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 14:51:45 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id c196so167350ioc.3
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 11:51:45 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 127sor210843itw.4.2017.12.12.11.51.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Dec 2017 11:51:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1712122017100.2289@nanos>
References: <20171212173221.496222173@linutronix.de> <20171212173334.345422294@linutronix.de>
 <CA+55aFwgGDa_JfZZPoaYtw5yE1oYnn1+0t51D=WU8a7__1Lauw@mail.gmail.com> <alpine.DEB.2.20.1712122017100.2289@nanos>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 12 Dec 2017 11:51:43 -0800
Message-ID: <CA+55aFxQwEW11tJ4mJ=tT1ofSBnvRxhiYykZRAHiuZbtNGSbpQ@mail.gmail.com>
Subject: Re: [patch 13/16] x86/ldt: Introduce LDT write fault handler
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, linux-mm <linux-mm@kvack.org>

On Tue, Dec 12, 2017 at 11:21 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
>
> That has nothing to do with the user installed LDT. The kernel does not use
> and rely on LDT at all.

Sure it does. We end up loading the selector for %gs and %fs, and
those selectors end up being connected with whatever user-mode has set
up for them.

We then set the FS/GS base pointer to a kernel-specific value, but
that is _separately_ from the actual accessed bit that is in the
selector.

So the kernel doesn't care, but the kernel definitely uses them.

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
