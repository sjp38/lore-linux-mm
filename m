Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0AFBF6B0005
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 12:42:53 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id a2so4294052pgn.7
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 09:42:53 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t83si2009353pfi.290.2018.02.09.09.42.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 09:42:51 -0800 (PST)
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 86ACF217A5
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 17:42:51 +0000 (UTC)
Received: by mail-io0-f176.google.com with SMTP id b198so10493277iof.6
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 09:42:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1518168340-9392-24-git-send-email-joro@8bytes.org>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org> <1518168340-9392-24-git-send-email-joro@8bytes.org>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 9 Feb 2018 17:42:18 +0000
Message-ID: <CALCETrV14cb4sosu8T_ZtL3cbb6cCV52uHr3ZKBqZ5+TjqZf2Q@mail.gmail.com>
Subject: Re: [PATCH 23/31] x86/mm/pti: Define X86_CR3_PTI_PCID_USER_BIT on x86_32
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, Joerg Roedel <jroedel@suse.de>

On Fri, Feb 9, 2018 at 9:25 AM, Joerg Roedel <joro@8bytes.org> wrote:
> From: Joerg Roedel <jroedel@suse.de>
>
> Move it out of the X86_64 specific processor defines so
> that its visible for 32bit too.
>
> Signed-off-by: Joerg Roedel <jroedel@suse.de>

Reviewed-by: Andy Lutomirski <luto@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
