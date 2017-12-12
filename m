Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4BCA36B0038
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 15:38:41 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id t92so66916wrc.13
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 12:38:41 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id f20si30575wrg.43.2017.12.12.12.38.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 12 Dec 2017 12:38:40 -0800 (PST)
Date: Tue, 12 Dec 2017 21:37:52 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [patch 13/16] x86/ldt: Introduce LDT write fault handler
In-Reply-To: <212680b8-6f8d-f785-42fd-61846553570d@intel.com>
Message-ID: <alpine.DEB.2.20.1712122124320.2289@nanos>
References: <20171212173221.496222173@linutronix.de> <20171212173334.345422294@linutronix.de> <CA+55aFwgGDa_JfZZPoaYtw5yE1oYnn1+0t51D=WU8a7__1Lauw@mail.gmail.com> <alpine.DEB.2.20.1712122017100.2289@nanos> <212680b8-6f8d-f785-42fd-61846553570d@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, linux-mm <linux-mm@kvack.org>

On Tue, 12 Dec 2017, Dave Hansen wrote:

> On 12/12/2017 11:21 AM, Thomas Gleixner wrote:
> > The only critical interaction is the return to user path (user CS/SS) and
> > we made sure with the LAR touching that these are precached in the CPU
> > before we go into fragile exit code.
> 
> How do we make sure that it _stays_ cached?
> 
> Surely there is weird stuff like WBINVD or SMI's that can come at very
> inconvenient times and wipe it out of the cache.

This does not look like cache in the sense of memory cache. It seems to be
CPU internal state and I just stuffed WBINVD and alternatively CLFLUSH'ed
the entries after the 'touch' via LAR. Still works.

Thanks,

	tglx



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
