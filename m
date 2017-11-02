Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5DF5F6B025F
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 07:21:14 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b9so2779898wmh.5
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 04:21:14 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id y29si2918401wry.87.2017.11.02.04.21.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 02 Nov 2017 04:21:13 -0700 (PDT)
Date: Thu, 2 Nov 2017 12:21:10 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 02/23] x86, kaiser: do not set _PAGE_USER for init_mm
 page tables
In-Reply-To: <CALCETrVa1rO9Jn0gh40Y_V_f_dE-1oPk25To29RD8Nb9GeMC2Q@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1711021220150.2090@nanos>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <20171031223150.AB41C68F@viggo.jf.intel.com> <alpine.DEB.2.20.1711012206050.1942@nanos> <CALCETrWQ0W=Kp7fycZ2E9Dp84CCPOr1nEmsPom71ZAXeRYqr9g@mail.gmail.com> <alpine.DEB.2.20.1711012225400.1942@nanos>
 <CALCETrVa1rO9Jn0gh40Y_V_f_dE-1oPk25To29RD8Nb9GeMC2Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On Thu, 2 Nov 2017, Andy Lutomirski wrote:
> On Wed, Nov 1, 2017 at 2:28 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> > On Wed, 1 Nov 2017, Andy Lutomirski wrote:
> >
> >> On Wed, Nov 1, 2017 at 2:11 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> >> > On Tue, 31 Oct 2017, Dave Hansen wrote:
> >> >
> >> >>
> >> >> init_mm is for kernel-exclusive use.  If someone is allocating page
> >> >> tables in it, do not set _PAGE_USER on them.  This ensures that
> >> >> we do *not* set NX on these page tables in the KAISER code.
> >> >
> >> > This changelog is confusing at best.
> >> >
> >> > Why is this a kaiser issue? Nothing should ever create _PAGE_USER entries
> >> > in init_mm, right?
> >>
> >> The vsyscall page is _PAGE_USER and lives in init_mm via the fixmap.
> >
> > Groan, forgot about that abomination, but still there is no point in having
> > it marked PAGE_USER in the init_mm at all, kaiser or not.
> >
> 
> How can it be PAGE_USER in user mms but not init_mm?  It's the same page table.

Right you are. Brain was already shutdown it seems.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
