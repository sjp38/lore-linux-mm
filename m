Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 347966B025E
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 14:05:25 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id u42so76501ioi.19
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 11:05:25 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i138sor151468ite.17.2017.12.12.11.05.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Dec 2017 11:05:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171212173334.176469949@linutronix.de>
References: <20171212173221.496222173@linutronix.de> <20171212173334.176469949@linutronix.de>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 12 Dec 2017 11:05:23 -0800
Message-ID: <CA+55aFwzkdB7FoVcmyqBvHu2HyE+pBe_KEgN5G3KJx8ZCGW_jQ@mail.gmail.com>
Subject: Re: [patch 11/16] x86/ldt: Force access bit for CS/SS
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, linux-mm <linux-mm@kvack.org>

On Tue, Dec 12, 2017 at 9:32 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
>
> There is one exception; IRET will immediately load CS/SS and unrecoverably
> #GP. To avoid this issue access the LDT descriptors used by CS/SS before
> the IRET to userspace.

Ok, so the other patch made me nervous, this just makes me go "Hell no!".

This is exactly the kind of "now we get traps in random microcode
places that have never been tested" kind of thing that I was talking
about.

Why is the iret exception unrecoverable anyway? Does anybody even know?

                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
