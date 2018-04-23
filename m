Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id C2CBD6B000E
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 13:49:15 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id x1-v6so9136516itb.8
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 10:49:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 129-v6sor4247474ioz.307.2018.04.23.10.49.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Apr 2018 10:49:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180423174506.mpbpnvfzv6fmpbzy@suse.de>
References: <1524498460-25530-1-git-send-email-joro@8bytes.org>
 <CA+55aFwg75rOXN5Q0qHf_GF-hnVo8mjxnTo2FbM993fuc8x7Gw@mail.gmail.com> <20180423174506.mpbpnvfzv6fmpbzy@suse.de>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 23 Apr 2018 10:49:13 -0700
Message-ID: <CA+55aFwt+o1kjgkVcxLbO_558J5zWMg_XpfmEkW2LW2eq1CiDQ@mail.gmail.com>
Subject: Re: [PATCH 00/37 v6] PTI support for x86-32
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <jroedel@suse.de>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>

On Mon, Apr 23, 2018 at 10:45 AM, Joerg Roedel <jroedel@suse.de> wrote:
>
> Just checked that and there are no pages with GLB and USR set, not even
> a vdso page.

Thanks.

> The vsyscall page does not exist on plain 32 bit, no? All I could find
> there is the vdso page, and that has no compat mapping anymore in recent
> upstream kernels. To my understanding the vdso page is mapped into the
> user-space portion of the address space. At least that is what I found
> while looking at this, but I might have missed something.

I guess it's just the x86-64 vsyscall page then. Thanks for checking.

                 Linus
