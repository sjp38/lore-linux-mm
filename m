Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 20B846B000E
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 14:02:35 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id f64so355372plb.7
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 11:02:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h6si1028952pgp.100.2018.02.09.11.02.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Feb 2018 11:02:33 -0800 (PST)
Date: Fri, 9 Feb 2018 20:02:26 +0100
From: Joerg Roedel <jroedel@suse.de>
Subject: Re: [PATCH 09/31] x86/entry/32: Leave the kernel via trampoline stack
Message-ID: <20180209190226.lqh6twf7thfg52cq@suse.de>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
 <1518168340-9392-10-git-send-email-joro@8bytes.org>
 <CA+55aFzB9H=RT6YB3onZCephZMs9ccz4aJ_jcPcfEkKJD_YDCQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzB9H=RT6YB3onZCephZMs9ccz4aJ_jcPcfEkKJD_YDCQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>

On Fri, Feb 09, 2018 at 09:05:02AM -0800, Linus Torvalds wrote:
> On Fri, Feb 9, 2018 at 1:25 AM, Joerg Roedel <joro@8bytes.org> wrote:
> > +
> > +       /* Copy over the stack-frame */
> > +       cld
> > +       rep movsb
> 
> Ugh. This is going to be horrendous. Maybe not noticeable on modern
> CPU's, but the whole 32-bit code is kind of pointless on a modern CPU.
> 
> At least use "rep movsl". If the kernel stack isn't 4-byte aligned,
> you have issues.

Okay, I used movsb because I remembered that being the recommendation
for the most efficient memcpy, and it safes me an instruction. But that
is probably only true on modern CPUs. I'll change it to use movsl here
and in the other patches.

Thanks,

	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
