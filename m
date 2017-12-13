Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 896636B0033
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 13:24:01 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id z30so1675133otd.9
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 10:24:01 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z6sor886214ota.202.2017.12.13.10.24.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Dec 2017 10:24:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <b40719da-a23b-72a4-ddde-54c2f5d96820@intel.com>
References: <20171212173221.496222173@linutronix.de> <20171212173333.669577588@linutronix.de>
 <CALCETrXLeGGw+g7GiGDmReXgOxjB-cjmehdryOsFK4JB5BJAFQ@mail.gmail.com>
 <20171213122211.bxcb7xjdwla2bqol@hirez.programming.kicks-ass.net>
 <20171213125739.fllckbl3o4nonmpx@node.shutemov.name> <b303fac7-34af-5065-f996-4494fb8c09a2@intel.com>
 <20171213153202.qtxnloxoc66lhsbf@hirez.programming.kicks-ass.net>
 <e6ef40c8-8966-c973-3ae4-ac9475699e40@intel.com> <20171213155427.p24i2xdh2s65e4d2@hirez.programming.kicks-ass.net>
 <CA+55aFw0JTRDXked3_OJ+cFx59BE18yDWOt7-ZRTzFS10zYnrg@mail.gmail.com> <b40719da-a23b-72a4-ddde-54c2f5d96820@intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 13 Dec 2017 10:23:59 -0800
Message-ID: <CA+55aFxjxm3qTaH2cw4o8eOxUjh0AcPW5U6mDc1SS3uRUBFGGA@mail.gmail.com>
Subject: Re: [patch 05/16] mm: Allow special mappings with user access cleared
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Aneesh Kumar K. V" <aneesh.kumar@linux.vnet.ibm.com>

On Wed, Dec 13, 2017 at 10:21 AM, Dave Hansen <dave.hansen@intel.com> wrote:
> On 12/13/2017 10:08 AM, Linus Torvalds wrote:
>> On Wed, Dec 13, 2017 at 7:54 AM, Peter Zijlstr <peterz@infradead.org> wrote:
>>> Which is why get_user_pages() _should_ enforce this.
>>>
>>> What use are protection keys if you can trivially circumvent them?
>> No, we will *not* worry about protection keys in get_user_pages().
>
> We did introduce some support for it here:
>
>> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=33a709b25a760b91184bb335cf7d7c32b8123013

Ugh. I never realized.

We should revert that, I feel. It's literally extra complexity for no
actual real gain, and there is a real downside: the extra complexity
that will cause people to get things wrong.

This thread about us getting it wrong is just the proof. I vote for
not trying to "fix" this case, let's just remove it.

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
