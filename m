Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id AC0CE28024A
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 17:46:38 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id i2so10058920pgq.8
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 14:46:38 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id z5si2892042plo.122.2018.01.16.14.46.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 14:46:37 -0800 (PST)
Received: from mail-it0-f44.google.com (mail-it0-f44.google.com [209.85.214.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 6A708217A1
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 22:46:37 +0000 (UTC)
Received: by mail-it0-f44.google.com with SMTP id x42so6836327ita.4
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 14:46:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1516120619-1159-5-git-send-email-joro@8bytes.org>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org> <1516120619-1159-5-git-send-email-joro@8bytes.org>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 16 Jan 2018 14:46:16 -0800
Message-ID: <CALCETrXFuXo+nDm0ovS6e7F5-aALMCwZdX=H6C=pLkAArDaYMQ@mail.gmail.com>
Subject: Re: [PATCH 04/16] x86/pti: Define X86_CR3_PTI_PCID_USER_BIT on x86_32
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Joerg Roedel <jroedel@suse.de>

On Tue, Jan 16, 2018 at 8:36 AM, Joerg Roedel <joro@8bytes.org> wrote:
> From: Joerg Roedel <jroedel@suse.de>
>
> Move it out of the X86_64 specific processor defines so
> that its visible for 32bit too.

Hmm.  This is okay, I guess, but any code that actually uses this
definition is inherently wrong, since 32-bit implies !PCID.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
