Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 140456B0253
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 13:35:02 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id f62so1678026otf.6
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 10:35:02 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n3sor898133ota.67.2017.12.13.10.35.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Dec 2017 10:35:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171213183209.GZ3165@worktop.lehotels.local>
References: <20171212173221.496222173@linutronix.de> <20171212173333.669577588@linutronix.de>
 <CALCETrXLeGGw+g7GiGDmReXgOxjB-cjmehdryOsFK4JB5BJAFQ@mail.gmail.com>
 <20171213122211.bxcb7xjdwla2bqol@hirez.programming.kicks-ass.net>
 <20171213125739.fllckbl3o4nonmpx@node.shutemov.name> <b303fac7-34af-5065-f996-4494fb8c09a2@intel.com>
 <20171213153202.qtxnloxoc66lhsbf@hirez.programming.kicks-ass.net>
 <e6ef40c8-8966-c973-3ae4-ac9475699e40@intel.com> <20171213155427.p24i2xdh2s65e4d2@hirez.programming.kicks-ass.net>
 <CA+55aFw0JTRDXked3_OJ+cFx59BE18yDWOt7-ZRTzFS10zYnrg@mail.gmail.com> <20171213183209.GZ3165@worktop.lehotels.local>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 13 Dec 2017 10:35:00 -0800
Message-ID: <CA+55aFzNhHZaAFJZv5=2t8dnUt9mMaZVp9_5XvayN6gkfEvtrA@mail.gmail.com>
Subject: Re: [patch 05/16] mm: Allow special mappings with user access cleared
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Dave Hansen <dave.hansen@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Aneesh Kumar K. V" <aneesh.kumar@linux.vnet.ibm.com>

On Wed, Dec 13, 2017 at 10:32 AM, Peter Zijlstra <peterz@infradead.org> wrote:
>
> Now, if VM_NOUSER were to live, the above change would ensure write(2)
> cannot read from such VMAs, where the existing test for FOLL_WRITE
> already disallows read(2) from writing to them.

So I don't mind at all the notion of disallowing access to some
special mappings at the vma level. So a VM_NOUSER flag that just
disallows get_user_pages entirely I'm ok with.

It's the protection keys in particular that I don't like having to
worry about. They are subtle and have odd architecture-specific
meaning, and needs to be checked at all levels in the page table tree.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
