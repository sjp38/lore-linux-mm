Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A41866B0260
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 17:28:30 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id q127so1932591wmd.1
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 14:28:30 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id c40si1374321wrc.47.2017.11.01.14.28.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 01 Nov 2017 14:28:29 -0700 (PDT)
Date: Wed, 1 Nov 2017 22:28:26 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 02/23] x86, kaiser: do not set _PAGE_USER for init_mm
 page tables
In-Reply-To: <CALCETrWQ0W=Kp7fycZ2E9Dp84CCPOr1nEmsPom71ZAXeRYqr9g@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1711012225400.1942@nanos>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <20171031223150.AB41C68F@viggo.jf.intel.com> <alpine.DEB.2.20.1711012206050.1942@nanos> <CALCETrWQ0W=Kp7fycZ2E9Dp84CCPOr1nEmsPom71ZAXeRYqr9g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On Wed, 1 Nov 2017, Andy Lutomirski wrote:

> On Wed, Nov 1, 2017 at 2:11 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> > On Tue, 31 Oct 2017, Dave Hansen wrote:
> >
> >>
> >> init_mm is for kernel-exclusive use.  If someone is allocating page
> >> tables in it, do not set _PAGE_USER on them.  This ensures that
> >> we do *not* set NX on these page tables in the KAISER code.
> >
> > This changelog is confusing at best.
> >
> > Why is this a kaiser issue? Nothing should ever create _PAGE_USER entries
> > in init_mm, right?
> 
> The vsyscall page is _PAGE_USER and lives in init_mm via the fixmap.

Groan, forgot about that abomination, but still there is no point in having
it marked PAGE_USER in the init_mm at all, kaiser or not.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
