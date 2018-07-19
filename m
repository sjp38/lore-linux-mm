Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7812E6B0003
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 16:52:13 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id w2-v6so4326055wrt.13
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 13:52:13 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id o16-v6si94144wrp.94.2018.07.19.13.52.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 19 Jul 2018 13:52:12 -0700 (PDT)
Date: Thu, 19 Jul 2018 22:52:04 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 07/39] x86/entry/32: Enter the kernel via trampoline
 stack
In-Reply-To: <CAMzpN2gqxu7rgVj8rfweanLNgHBci+nqZMqEYpvgRUd1828umQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.21.1807192250360.1693@nanos.tec.linutronix.de>
References: <1531906876-13451-1-git-send-email-joro@8bytes.org> <1531906876-13451-8-git-send-email-joro@8bytes.org> <CAMzpN2gqxu7rgVj8rfweanLNgHBci+nqZMqEYpvgRUd1828umQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Gerst <brgerst@gmail.com>
Cc: Joerg Roedel <joro@8bytes.org>, Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, dhgutteridge@sympatico.ca, Joerg Roedel <jroedel@suse.de>

On Wed, 18 Jul 2018, Brian Gerst wrote:
> > +.Lcopy_pt_regs_\@:
> > +#endif
> > +
> > +       /* Allocate frame on task-stack */
> > +       subl    %ecx, %edi
> > +
> > +       /* Switch to task-stack */
> > +       movl    %edi, %esp
> > +
> > +       /*
> > +        * We are now on the task-stack and can safely copy over the
> > +        * stack-frame
> > +        */
> > +       shrl    $2, %ecx
> 
> This shift can be removed if you divide the constants by 4 above.
> Ditto on the exit path in the next patch.

No, the

> > +       /* Allocate frame on task-stack */
> > +       subl    %ecx, %edi

needs the full value in bytes ....

Thanks,

	tglx
