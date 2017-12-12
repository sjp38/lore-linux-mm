Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 755946B0069
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 16:42:44 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 55so142343wrx.21
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 13:42:44 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id i143si330722wmd.222.2017.12.12.13.42.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 12 Dec 2017 13:42:43 -0800 (PST)
Date: Tue, 12 Dec 2017 22:42:14 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [patch 13/16] x86/ldt: Introduce LDT write fault handler
In-Reply-To: <CALCETrVt8zzfoszh83N0dT9TEax3pr+HLauprKWD2FssvFYXYA@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1712122241220.2289@nanos>
References: <20171212173221.496222173@linutronix.de> <20171212173334.345422294@linutronix.de> <CA+55aFwgGDa_JfZZPoaYtw5yE1oYnn1+0t51D=WU8a7__1Lauw@mail.gmail.com> <alpine.DEB.2.20.1712122017100.2289@nanos> <212680b8-6f8d-f785-42fd-61846553570d@intel.com>
 <alpine.DEB.2.20.1712122124320.2289@nanos> <CALCETrVt8zzfoszh83N0dT9TEax3pr+HLauprKWD2FssvFYXYA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, linux-mm <linux-mm@kvack.org>

On Tue, 12 Dec 2017, Andy Lutomirski wrote:

> On Tue, Dec 12, 2017 at 12:37 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> > On Tue, 12 Dec 2017, Dave Hansen wrote:
> >
> >> On 12/12/2017 11:21 AM, Thomas Gleixner wrote:
> >> > The only critical interaction is the return to user path (user CS/SS) and
> >> > we made sure with the LAR touching that these are precached in the CPU
> >> > before we go into fragile exit code.
> >>
> >> How do we make sure that it _stays_ cached?
> >>
> >> Surely there is weird stuff like WBINVD or SMI's that can come at very
> >> inconvenient times and wipe it out of the cache.
> >
> > This does not look like cache in the sense of memory cache. It seems to be
> > CPU internal state and I just stuffed WBINVD and alternatively CLFLUSH'ed
> > the entries after the 'touch' via LAR. Still works.
> >
> 
> There *must* be some weird bug in this series.  I find it very hard to
> believe that x86 CPUs have a magic cache that caches any part of a
> not-actually-in-a-segment-register descriptor entry.

There is no bug in the code. There was just a bug in my brain which made me
fail to see the obvious. See the other mail.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
