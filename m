Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 975416B0038
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 17:50:04 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id r6so11327182itr.1
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 14:50:04 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n8sor3295579itn.147.2017.12.14.14.50.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Dec 2017 14:50:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1712142321440.2257@nanos>
References: <20171214112726.742649793@infradead.org> <20171214113851.647809433@infradead.org>
 <CALCETrW0=FnqZMU_MLebyy5m7jj=w=yHYx=u6vghFkdmG7vsww@mail.gmail.com>
 <CA+55aFz71Ycm3oez30zOCztx1sio8ioy3VED2rE0ORoExXBz2g@mail.gmail.com>
 <CALCETrU8=z92_ZtwR9EO56eeOBE1LbxOqigZGO_yahmcM2dE_A@mail.gmail.com>
 <CA+55aFyNN4Lhf4RhL95oeGvfng=H4wKSA3-MwzMo=KpBocQ7bA@mail.gmail.com> <alpine.DEB.2.20.1712142321440.2257@nanos>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 14 Dec 2017 14:50:02 -0800
Message-ID: <CA+55aFxnx98JLdpnjrvPZ+BDY_0dY+1GbCKRVki8b+-af+MM=g@mail.gmail.com>
Subject: Re: [PATCH v2 11/17] selftests/x86/ldt_gdt: Prepare for access bit forced
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On Thu, Dec 14, 2017 at 2:23 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
>
> The user knows the LDT contents because he put it there and it can be read
> via modify_ldt(0, ) anyway. Or am I misunderstanding what you are trying to
> say?

I don't think they are secret, it's more of a "if they can read it,
they can write it" kind of thing.

The whole "it should be RO" makes no sense. The first choice should be
"it should be inaccessible".

And that actually seems the _simpler_ choice.

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
