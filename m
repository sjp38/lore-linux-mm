Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 756836B0038
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 12:58:16 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id v25so18438954pfg.14
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 09:58:16 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g14si9433258plj.470.2017.12.12.09.58.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Dec 2017 09:58:15 -0800 (PST)
Received: from mail-it0-f41.google.com (mail-it0-f41.google.com [209.85.214.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id DD562204EE
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 17:58:14 +0000 (UTC)
Received: by mail-it0-f41.google.com with SMTP id b5so506850itc.3
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 09:58:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171212173334.097591438@linutronix.de>
References: <20171212173221.496222173@linutronix.de> <20171212173334.097591438@linutronix.de>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 12 Dec 2017 09:57:52 -0800
Message-ID: <CALCETrWQ-u82-CvECyiX0U1oNhb3Cnp2rq7z3HLbpQ434FQeSA@mail.gmail.com>
Subject: Re: [patch 10/16] x86/ldt: Do not install LDT for kernel threads
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Dec 12, 2017 at 9:32 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> From: Thomas Gleixner <tglx@linutronix.de>
>
> Kernel threads can use the mm of a user process temporarily via use_mm(),
> but there is no point in installing the LDT which is associated to that mm
> for the kernel thread.
>

I like this one.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
