Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1F9B66B0008
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 13:06:23 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id j139so7833000vke.8
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 10:06:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m129sor6303112vkg.287.2018.04.23.10.06.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Apr 2018 10:06:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1524498460-25530-28-git-send-email-joro@8bytes.org>
References: <1524498460-25530-1-git-send-email-joro@8bytes.org> <1524498460-25530-28-git-send-email-joro@8bytes.org>
From: Kees Cook <keescook@google.com>
Date: Mon, 23 Apr 2018 10:06:20 -0700
Message-ID: <CAGXu5jLN_rzmfgM-Xne836ip+qMc8T1QX=mhozo3NFLNssgUfw@mail.gmail.com>
Subject: Re: [PATCH 27/37] x86/mm/pti: Keep permissions when cloning kernel
 text in pti_clone_kernel_text()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, Anthony Liguori <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, Joerg Roedel <jroedel@suse.de>

On Mon, Apr 23, 2018 at 8:47 AM, Joerg Roedel <joro@8bytes.org> wrote:
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

Why are there R/W text mappings in this range? I find that to be
unexpected. Shouldn't CONFIG_DEBUG_WX already complain if that were
true?

-Kees

-- 
Kees Cook
Pixel Security
