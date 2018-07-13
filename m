Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 561656B027B
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 19:25:49 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a23-v6so9939945pfo.23
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 16:25:49 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s184-v6si23468090pgb.123.2018.07.13.16.25.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 16:25:48 -0700 (PDT)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id AA993208E2
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 23:25:47 +0000 (UTC)
Received: by mail-wm0-f51.google.com with SMTP id s14-v6so10769019wmc.1
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 16:25:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1531308586-29340-29-git-send-email-joro@8bytes.org>
References: <1531308586-29340-1-git-send-email-joro@8bytes.org> <1531308586-29340-29-git-send-email-joro@8bytes.org>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 13 Jul 2018 16:25:25 -0700
Message-ID: <CALCETrXj7TT5tm8m+9ycuRDDWDiqQy4u5gLLVrz8DhNWWw1fXA@mail.gmail.com>
Subject: Re: [PATCH 28/39] x86/mm/pti: Keep permissions when cloning kernel
 text in pti_clone_kernel_text()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, Joerg Roedel <jroedel@suse.de>

On Wed, Jul 11, 2018 at 4:29 AM, Joerg Roedel <joro@8bytes.org> wrote:
> From: Joerg Roedel <jroedel@suse.de>
>
> Mapping the kernel text area to user-space makes only sense
> if it has the same permissions as in the kernel page-table.
> If permissions are different this will cause a TLB reload
> when using the kernel page-table, which is as good as not
> mapping it at all.
>
> On 64-bit kernels this patch makes no difference, as the
> whole range cloned by pti_clone_kernel_text() is mapped RO
> anyway. On 32 bit there are writeable mappings in the range,
> so just keep the permissions as they are.

Reviewed-by: Andy Lutomirski <luto@kernel.org>
