Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 73AD46B026F
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 12:13:25 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id m134-v6so9665468itb.9
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 09:13:25 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a64sor5032028iog.168.2018.04.16.09.13.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Apr 2018 09:13:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180416160154.GE15462@8bytes.org>
References: <1523892323-14741-1-git-send-email-joro@8bytes.org>
 <CA+55aFwGTOgSonVquab63PZG5z_NfgVF2A08iHaNeeqY5pdfnA@mail.gmail.com> <20180416160154.GE15462@8bytes.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 16 Apr 2018 09:13:22 -0700
Message-ID: <CA+55aFzrYbTMXyZBVqRV875HwQJNxD+822RGeeDb7BLDLU8aWA@mail.gmail.com>
Subject: Re: [PATCH 00/35 v5] PTI support for x32
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, Joerg Roedel <jroedel@suse.de>

On Mon, Apr 16, 2018 at 9:01 AM, Joerg Roedel <joro@8bytes.org> wrote:
>
> Okay, I verify if there are any global bits left in the page-tables.
> According to the PTDUMP_X86 the cpu_entry_area is mapped with G=1 (which
> should be fine?) and another 4M range in the kernel mapping. I need to
> check what that is.

All the kernel entry code that is both in the user mapping and the
kernel mapping should be marked G.

We had missed a lot of it (and the impact is very small with PCID),
but if you rebased on top of 4.17-rc1 you should have it fixed at
least on 64-bit.

See for example commit 8c06c7740d19 ("x86/pti: Leave kernel text
global for !PCID") and in particular the performance numbers (that's
an Atom microserver, but it was chosen due to lack of PCID).

                  Linus
