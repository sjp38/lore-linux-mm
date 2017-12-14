Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id B267B6B0033
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 17:14:02 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id o66so10874268ita.3
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 14:14:02 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m67sor503302ioo.96.2017.12.14.14.14.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Dec 2017 14:14:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171214220226.GL3326@worktop>
References: <20171214112726.742649793@infradead.org> <20171214113851.647809433@infradead.org>
 <CALCETrW0=FnqZMU_MLebyy5m7jj=w=yHYx=u6vghFkdmG7vsww@mail.gmail.com>
 <CA+55aFz71Ycm3oez30zOCztx1sio8ioy3VED2rE0ORoExXBz2g@mail.gmail.com>
 <CALCETrU8=z92_ZtwR9EO56eeOBE1LbxOqigZGO_yahmcM2dE_A@mail.gmail.com>
 <CA+55aFyNN4Lhf4RhL95oeGvfng=H4wKSA3-MwzMo=KpBocQ7bA@mail.gmail.com>
 <CA+55aFxmwpkDNT0YcaiG-BQ5SUT6h6YkevVfNkU_eY-F2E-h7Q@mail.gmail.com> <20171214220226.GL3326@worktop>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 14 Dec 2017 14:14:00 -0800
Message-ID: <CA+55aFzT=+Vc75O8yjGYcSiWVVvrRMOZT2Ydhs7S=0RUAtscAA@mail.gmail.com>
Subject: Re: [PATCH v2 11/17] selftests/x86/ldt_gdt: Prepare for access bit forced
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andy Lutomirski <luto@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, X86 ML <x86@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On Thu, Dec 14, 2017 at 2:02 PM, Peter Zijlstra <peterz@infradead.org> wrote:
>
> _Should_ being the operative word, because I cannot currently see it
> DTRT. But maybe I'm missing the obvious -- I tend to do that at times.

At least the old get_user_pages_fast() code used to check the USER bit:

        unsigned long need_pte_bits = _PAGE_PRESENT|_PAGE_USER;

        if (write)
                need_pte_bits |= _PAGE_RW;

but that may have been lost when we converted over to the generic code.

It shouldn't actually _matter_, since we'd need to change access_ok()
anyway (and gup had better check that!)

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
