Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id AA4866B0266
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 20:11:00 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id b11so16841440itj.0
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 17:11:00 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j67sor3748091ith.139.2017.12.15.17.10.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Dec 2017 17:10:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAPcyv4hFCHGNadbMv8iTsLqbWm9rkBc7ww-Zax9tjaMJGrXu+w@mail.gmail.com>
References: <20171214112726.742649793@infradead.org> <20171214113851.146259969@infradead.org>
 <20171214124117.wfzcjdczyta2sery@hirez.programming.kicks-ass.net>
 <20171214143730.s6w7sd6c7b5t6fqp@hirez.programming.kicks-ass.net>
 <f0244eb7-bd9f-dce4-68a5-cf5f8b43652e@intel.com> <20171214205450.GI3326@worktop>
 <8eedb9a3-0ba2-52df-58f6-3ed869d18ca3@intel.com> <CA+55aFyA1+_hnqKO11gVNTo7RV6d9qygC-p8yiAzFMb=9aR5-A@mail.gmail.com>
 <20171215075147.nzpsmb7asyr6etig@hirez.programming.kicks-ass.net>
 <CA+55aFxdHSYYA0HOctCXeqLMjku8WjuAcddCGR_Lr5sOfca10Q@mail.gmail.com> <CAPcyv4hFCHGNadbMv8iTsLqbWm9rkBc7ww-Zax9tjaMJGrXu+w@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 15 Dec 2017 17:10:58 -0800
Message-ID: <CA+55aFz2aY-0hG1E_x7Don1pwgDQkHZfP2J3qW+QbvcvLBWTNQ@mail.gmail.com>
Subject: Re: [PATCH v2 01/17] mm/gup: Fixup p*_access_permitted()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, the arch/x86 maintainers <x86@kernel.org>, Andy Lutomirsky <luto@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, linux-mm <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri, Dec 15, 2017 at 4:29 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> So do you want to do a straight revert of these that went in for 4.15:

I think that's the right thing to do, but would want to verify that
there are no *other* issues than just the attempt at PKRU.

The commit message does talk about PAGE_USER, and as mentioned I do
think that's a good thing to check, I just don't think it should be
done this way,

Was there something else going behind these commits? Because if not,
let's revert and then perhaps later introduce a more targeted thing?

Also, aren't the protection keys encoded in the vma?

Because *if* we want to check protection keys, I think we should do
that at the vma layer, partly exactly because the exact implementation
of protection keys is so architecture-specific, and partly because I
don't think it makes sense to check them for every page anyway.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
