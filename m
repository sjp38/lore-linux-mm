Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id E11276B0069
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 04:06:46 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z55so875971wrz.2
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 01:06:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d17sor2487wra.44.2017.11.01.01.06.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Nov 2017 01:06:45 -0700 (PDT)
Date: Wed, 1 Nov 2017 09:06:42 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 12/23] x86, kaiser: map dynamically-allocated LDTs
Message-ID: <20171101080642.6rvmrt3ec6d27zki@gmail.com>
References: <20171031223146.6B47C861@viggo.jf.intel.com>
 <20171031223208.F271E813@viggo.jf.intel.com>
 <CALCETrVbGHJUeZP2X36s-gUcEywpv_uuAwZRVAJWL5U8DijPkQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrVbGHJUeZP2X36s-gUcEywpv_uuAwZRVAJWL5U8DijPkQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>


* Andy Lutomirski <luto@kernel.org> wrote:

> On Tue, Oct 31, 2017 at 3:32 PM, Dave Hansen
> <dave.hansen@linux.intel.com> wrote:
> >
> > Normally, a process just has a NULL mm->context.ldt.  But, we
> > have a syscall for a process to set a new one.  If a process does
> > that, we need to map the new LDT.
> >
> > The original KAISER patch missed this case.
> 
> Tglx suggested that we instead increase the padding at the top of the
> user address space from 4k to 64k and put the LDT there.  This is a
> slight ABI break, but I'd be rather surprised if anything noticed,
> especially because the randomized vdso currently regularly lands there
> (IIRC), so any user code that explicitly uses those 60k already
> collides with the vdso.
> 
> I can make this happen.

Yes, let's try that.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
