Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C9D1A28024A
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 16:20:47 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id r82so2801914wme.0
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 13:20:47 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id b62si2455832wma.55.2018.01.16.13.20.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 16 Jan 2018 13:20:46 -0800 (PST)
Date: Tue, 16 Jan 2018 22:20:40 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [RFC PATCH 00/16] PTI support for x86-32
In-Reply-To: <1516120619-1159-1-git-send-email-joro@8bytes.org>
Message-ID: <alpine.DEB.2.20.1801162212080.2366@nanos>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, jroedel@suse.de

On Tue, 16 Jan 2018, Joerg Roedel wrote:
> here is my current WIP code to enable PTI on x86-32. It is
> still in a pretty early state, but it successfully boots my
> KVM guest with PAE and with legacy paging. The existing PTI
> code for x86-64 already prepares a lot of the stuff needed
> for 32 bit too, thanks for that to all the people involved
> in its development :)

>  16 files changed, 333 insertions(+), 123 deletions(-)

Impressively small and well done !

Can you please make that patch set against

   git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git x86-pti-for-linus

so we immediately have it backportable for 4.14 stable? It's only a trivial
conflict in pgtable.h, but we'd like to make the life of stable as simple
as possible. They have enough headache with the pre 4.14 trees.

We can pick some of the simple patches which make defines and inlines
available out of the pile right away and apply them to x86/pti to shrink
the amount of stuff you have to worry about.

Thanks,

	tglx


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
