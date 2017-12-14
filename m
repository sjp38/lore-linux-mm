Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3ACB36B0033
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 17:24:38 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id w141so3209522wme.1
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 14:24:38 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id n13si3772340wmg.102.2017.12.14.14.24.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 14 Dec 2017 14:24:37 -0800 (PST)
Date: Thu, 14 Dec 2017 23:23:55 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2 11/17] selftests/x86/ldt_gdt: Prepare for access bit
 forced
In-Reply-To: <CA+55aFyNN4Lhf4RhL95oeGvfng=H4wKSA3-MwzMo=KpBocQ7bA@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1712142321440.2257@nanos>
References: <20171214112726.742649793@infradead.org> <20171214113851.647809433@infradead.org> <CALCETrW0=FnqZMU_MLebyy5m7jj=w=yHYx=u6vghFkdmG7vsww@mail.gmail.com> <CA+55aFz71Ycm3oez30zOCztx1sio8ioy3VED2rE0ORoExXBz2g@mail.gmail.com>
 <CALCETrU8=z92_ZtwR9EO56eeOBE1LbxOqigZGO_yahmcM2dE_A@mail.gmail.com> <CA+55aFyNN4Lhf4RhL95oeGvfng=H4wKSA3-MwzMo=KpBocQ7bA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On Thu, 14 Dec 2017, Linus Torvalds wrote:

> On Thu, Dec 14, 2017 at 1:22 PM, Andy Lutomirski <luto@kernel.org> wrote:
> >
> > Which kind of kills the whole thing.  There's no way the idea of
> > putting the LDT in a VMA is okay if it's RW.
> 
> Sure there is.
> 
> I really don't understand why you guys think it has to be RO.
> 
> All it has to be is not _user_ accessible. And that's a requirement
> regardless, because no way in hell should users be able to read the
> damn thing.

The user knows the LDT contents because he put it there and it can be read
via modify_ldt(0, ) anyway. Or am I misunderstanding what you are trying to
say?

Thanks,

	tglx


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
