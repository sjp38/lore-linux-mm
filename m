Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id D3BA16B0003
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 12:45:40 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id s11-v6so14658176ioa.8
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 09:45:40 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o185-v6sor4183166ita.138.2018.04.23.09.45.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Apr 2018 09:45:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1524498460-25530-1-git-send-email-joro@8bytes.org>
References: <1524498460-25530-1-git-send-email-joro@8bytes.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 23 Apr 2018 09:45:38 -0700
Message-ID: <CA+55aFwg75rOXN5Q0qHf_GF-hnVo8mjxnTo2FbM993fuc8x7Gw@mail.gmail.com>
Subject: Re: [PATCH 00/37 v6] PTI support for x86-32
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, Joerg Roedel <jroedel@suse.de>

On Mon, Apr 23, 2018 at 8:47 AM, Joerg Roedel <joro@8bytes.org> wrote:
>
> here is the new version of my PTI patches for x86-32 which
> implement last weeks review comments.

Just one question: have you checked the page table setup for the
basics wrt the USER bit in particular?

No global pages should be marked PAGE_USER, with the possible
exception of that nasty old vsyscall page.

And it would be nice to verify that the page tables for kernel
mappings also don't have PAGE_USER on them, although again that
vsyscall page can cause problems.

                  Linus
