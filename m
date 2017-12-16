Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id EB8676B0038
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 22:00:58 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id r140so3597777iod.12
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 19:00:58 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l99sor39047ioi.304.2017.12.15.19.00.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Dec 2017 19:00:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFzehO00PH-WQuHJroRddiRMyLhO66b4Cv2sJA=7D2CeAw@mail.gmail.com>
References: <f0244eb7-bd9f-dce4-68a5-cf5f8b43652e@intel.com>
 <20171214205450.GI3326@worktop> <8eedb9a3-0ba2-52df-58f6-3ed869d18ca3@intel.com>
 <CA+55aFyA1+_hnqKO11gVNTo7RV6d9qygC-p8yiAzFMb=9aR5-A@mail.gmail.com>
 <20171215075147.nzpsmb7asyr6etig@hirez.programming.kicks-ass.net>
 <CA+55aFxdHSYYA0HOctCXeqLMjku8WjuAcddCGR_Lr5sOfca10Q@mail.gmail.com>
 <CAPcyv4hFCHGNadbMv8iTsLqbWm9rkBc7ww-Zax9tjaMJGrXu+w@mail.gmail.com>
 <CA+55aFz2aY-0hG1E_x7Don1pwgDQkHZfP2J3qW+QbvcvLBWTNQ@mail.gmail.com>
 <629d90d9-df33-2c31-e644-0bc356b61f25@intel.com> <CA+55aFxcA4Ht2urZY+ZvaTHKDjOHH5NqPWHCrvZYnsG=EOx4jQ@mail.gmail.com>
 <20171216024824.GK21978@ZenIV.linux.org.uk> <CA+55aFzehO00PH-WQuHJroRddiRMyLhO66b4Cv2sJA=7D2CeAw@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 15 Dec 2017 19:00:57 -0800
Message-ID: <CA+55aFx0o6+SxEhDrML+JL_2deifeb9TxJDrqt=KgMs=qZEa6A@mail.gmail.com>
Subject: Re: [PATCH v2 01/17] mm/gup: Fixup p*_access_permitted()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Peter Zijlstra <peterz@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, the arch/x86 maintainers <x86@kernel.org>, Andy Lutomirsky <luto@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, linux-mm <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri, Dec 15, 2017 at 6:52 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> However, since the main use case of protection keys is probably
> databases (Dave?) and since those also might be performance-sensitive
> about direct-IO doing page table lookups, it might not be great in
> practice.

Anyway, I reverted the three commits Dan pointed to, and we can always
revisit the exact path forward later

Because regardless of what the eventual future checks will be, for
4.15 I think we'll just go back to doing what we used to do.

If somebody sees problems, holler.

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
