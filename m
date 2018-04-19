Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6EC0B6B0005
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 20:02:04 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id y4-v6so3069969iod.5
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 17:02:04 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 185-v6sor1371987itw.107.2018.04.18.17.02.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Apr 2018 17:02:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <87k1t4t7tw.fsf@linux.intel.com>
References: <1523892323-14741-1-git-send-email-joro@8bytes.org>
 <1523892323-14741-4-git-send-email-joro@8bytes.org> <87k1t4t7tw.fsf@linux.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 18 Apr 2018 17:02:02 -0700
Message-ID: <CA+55aFxKzsPQW4S4esvJY=wb7D3LKBdDDcXoMKJSqcOgnD3FuA@mail.gmail.com>
Subject: Re: [PATCH 03/35] x86/entry/32: Load task stack from x86_tss.sp1 in
 SYSENTER handler
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waim@linux.intel.com

On Wed, Apr 18, 2018 at 4:26 PM, Andi Kleen <ak@linux.intel.com> wrote:
>
> Seems like a hack. Why can't that be stored in a per cpu variable?

It *is* a percpu variable - the whole x86_tss structure is percpu.

I guess it could be a different (separate) percpu variable, but might
as well use the space we already have allocated.

             Linus
