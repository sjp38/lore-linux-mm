Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 253246B0007
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 11:32:48 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id y131-v6so9507454itc.5
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 08:32:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 191sor6179020ioe.271.2018.04.16.08.32.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Apr 2018 08:32:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1523892323-14741-1-git-send-email-joro@8bytes.org>
References: <1523892323-14741-1-git-send-email-joro@8bytes.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 16 Apr 2018 08:32:46 -0700
Message-ID: <CA+55aFwGTOgSonVquab63PZG5z_NfgVF2A08iHaNeeqY5pdfnA@mail.gmail.com>
Subject: Re: [PATCH 00/35 v5] PTI support for x32
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, Joerg Roedel <jroedel@suse.de>

On Mon, Apr 16, 2018 at 8:24 AM, Joerg Roedel <joro@8bytes.org> wrote:
>
> I tested this version again with my load-test of running
> perf-top/various x86-selftests/kernel-compile in a loop for
> a couple of hours. This showed no issues. I also briefly
> tested a 64bit kernel and this also worked as expected.

Andy, can you send your extra x86 self-tests to Joerg too?

Also, it would be nice to have performance numbers, and check that the
global page issues are at least fixed on 32-bit too, since we screwed
that up on x86-64 initially.

On x86-32, the global pages are likely a bigger deal since there's no PCID.

                  Linus
