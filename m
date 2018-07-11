Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id CBA1C6B026D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 12:28:51 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id w23-v6so22553631ioa.1
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 09:28:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x19-v6sor7280523jaj.140.2018.07.11.09.28.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Jul 2018 09:28:50 -0700 (PDT)
MIME-Version: 1.0
References: <1531308586-29340-1-git-send-email-joro@8bytes.org>
In-Reply-To: <1531308586-29340-1-git-send-email-joro@8bytes.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 11 Jul 2018 09:28:39 -0700
Message-ID: <CA+55aFzrG+GV5ySVUiiod8Va5P0_vmUuh25Pner1r7c_aQgH9g@mail.gmail.com>
Subject: Re: [PATCH 00/39 v7] PTI support for x86-32
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, =?UTF-8?B?SsO8cmdlbiBHcm/Dnw==?= <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, Joerg Roedel <jroedel@suse.de>

On Wed, Jul 11, 2018 at 4:30 AM Joerg Roedel <joro@8bytes.org> wrote:
>
> I did the load-testing again with 'perf top', the ldt_gdt
> self-test and a kernel-compile running in a loop again.

So none of the patches looked scary to me, but then, neither did
earlier versions.

It's the testing that worries me most. Pretty much no developers run
32-bit any more, and I'd be most worried about the odd interactions
that might be hw-specific. Some crazy EFI mapping setup or the similar
odd case that simply requires a particular configuration or setup.

But I guess those issues will never be found until we just spring this
all on the unsuspecting public.

                 Linus
