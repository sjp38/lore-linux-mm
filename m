Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id DA2696B0038
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 13:08:32 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id k186so3364342ith.1
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 10:08:32 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y73sor1029686iof.288.2017.12.13.10.08.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Dec 2017 10:08:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171213155427.p24i2xdh2s65e4d2@hirez.programming.kicks-ass.net>
References: <20171212173221.496222173@linutronix.de> <20171212173333.669577588@linutronix.de>
 <CALCETrXLeGGw+g7GiGDmReXgOxjB-cjmehdryOsFK4JB5BJAFQ@mail.gmail.com>
 <20171213122211.bxcb7xjdwla2bqol@hirez.programming.kicks-ass.net>
 <20171213125739.fllckbl3o4nonmpx@node.shutemov.name> <b303fac7-34af-5065-f996-4494fb8c09a2@intel.com>
 <20171213153202.qtxnloxoc66lhsbf@hirez.programming.kicks-ass.net>
 <e6ef40c8-8966-c973-3ae4-ac9475699e40@intel.com> <20171213155427.p24i2xdh2s65e4d2@hirez.programming.kicks-ass.net>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 13 Dec 2017 10:08:30 -0800
Message-ID: <CA+55aFw0JTRDXked3_OJ+cFx59BE18yDWOt7-ZRTzFS10zYnrg@mail.gmail.com>
Subject: Re: [patch 05/16] mm: Allow special mappings with user access cleared
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Dave Hansen <dave.hansen@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Aneesh Kumar K. V" <aneesh.kumar@linux.vnet.ibm.com>

On Wed, Dec 13, 2017 at 7:54 AM, Peter Zijlstra <peterz@infradead.org> wrote:
>
> Which is why get_user_pages() _should_ enforce this.
>
> What use are protection keys if you can trivially circumvent them?

No, we will *not* worry about protection keys in get_user_pages().

They are not "security". They are a debug aid and safety against random mis-use.

In particular, they are very much *NOT* about "trivially circumvent
them". The user could just change their mapping thing, for chrissake!

We already allow access to PROT_NONE for gdb and friends, very much on purpose.

We're not going to make the VM more complex for something that
absolutely nobody cares about, and has zero security issues.

                        Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
