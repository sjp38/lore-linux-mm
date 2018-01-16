Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 731D528024A
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 17:26:45 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id g2so1399623pfh.9
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 14:26:45 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u14si2403223pgo.179.2018.01.16.14.26.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 14:26:44 -0800 (PST)
Received: from mail-it0-f41.google.com (mail-it0-f41.google.com [209.85.214.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9181721799
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 22:26:43 +0000 (UTC)
Received: by mail-it0-f41.google.com with SMTP id x42so6783121ita.4
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 14:26:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1516120619-1159-1-git-send-email-joro@8bytes.org>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 16 Jan 2018 14:26:22 -0800
Message-ID: <CALCETrWfetqrcUavH79akLgsMMWjE6JiW9c3OztYTk6Zv_RT1g@mail.gmail.com>
Subject: Re: [RFC PATCH 00/16] PTI support for x86-32
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Joerg Roedel <jroedel@suse.de>

On Tue, Jan 16, 2018 at 8:36 AM, Joerg Roedel <joro@8bytes.org> wrote:
> From: Joerg Roedel <jroedel@suse.de>
>
> Hi,
>
> here is my current WIP code to enable PTI on x86-32. It is
> still in a pretty early state, but it successfully boots my
> KVM guest with PAE and with legacy paging. The existing PTI
> code for x86-64 already prepares a lot of the stuff needed
> for 32 bit too, thanks for that to all the people involved
> in its development :)
>
> The patches are split as follows:
>
>         - 1-3 contain the entry-code changes to enter and
>           exit the kernel via the sysenter trampoline stack.
>
>         - 4-7 are fixes to get the code compile on 32 bit
>           with CONFIG_PAGE_TABLE_ISOLATION=y.
>
>         - 8-14 adapt the existing PTI code to work properly
>           on 32 bit and add the needed parts to 32 bit
>           page-table code.
>
>         - 15 switches PTI on by adding the CR3 switches to
>           kernel entry/exit.
>
>         - 16 enables the Kconfig for all of X86
>
> The code has not run on bare-metal yet, I'll test that in
> the next days once I setup a 32 bit box again. I also havn't
> tested Wine and DosEMU yet, so this might also be broken.
>

If you pass all the x86 selftests, then Wine and DOSEMU are pretty
likely to work :)

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
