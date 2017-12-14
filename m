Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 659416B0033
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 14:43:22 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id g202so10114706ita.4
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 11:43:22 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a16sor2434804itc.124.2017.12.14.11.43.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Dec 2017 11:43:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALCETrW0=FnqZMU_MLebyy5m7jj=w=yHYx=u6vghFkdmG7vsww@mail.gmail.com>
References: <20171214112726.742649793@infradead.org> <20171214113851.647809433@infradead.org>
 <CALCETrW0=FnqZMU_MLebyy5m7jj=w=yHYx=u6vghFkdmG7vsww@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 14 Dec 2017 11:43:20 -0800
Message-ID: <CA+55aFz71Ycm3oez30zOCztx1sio8ioy3VED2rE0ORoExXBz2g@mail.gmail.com>
Subject: Re: [PATCH v2 11/17] selftests/x86/ldt_gdt: Prepare for access bit forced
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, X86 ML <x86@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On Thu, Dec 14, 2017 at 8:20 AM, Andy Lutomirski <luto@kernel.org> wrote:
>
> If this turns out to need reverting because it breaks Wine or
> something, we're really going to regret it.

I really don't see that as very likely. We already play other (much
more fundamental) games with segments.

But I do agree that it would be good to consider this "turn LDT
read-only" a separate series just in case.

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
