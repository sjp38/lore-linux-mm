Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 04CB86B0035
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 06:16:49 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id hz1so5088709pad.36
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 03:16:46 -0700 (PDT)
Received: from cam-admin0.cambridge.arm.com (cam-admin0.cambridge.arm.com. [217.140.96.50])
        by mx.google.com with ESMTP id aa10si5431014pac.16.2014.07.18.03.16.42
        for <linux-mm@kvack.org>;
        Fri, 18 Jul 2014 03:16:43 -0700 (PDT)
Date: Fri, 18 Jul 2014 11:14:16 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v3] arm64,ia64,ppc,s390,sh,tile,um,x86,mm: Remove default
 gate area
Message-ID: <20140718101416.GB1818@arm.com>
References: <70f331f59e620dc4e66bd3fa095e6f6b744b532b.1405281639.git.luto@amacapital.net>
 <CALCETrXG6nL4K=Er+kv5-CXBDVa0TLg9yR6iePnMyE2ufXgKkw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrXG6nL4K=Er+kv5-CXBDVa0TLg9yR6iePnMyE2ufXgKkw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Catalin Marinas <Catalin.Marinas@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "linux390@de.ibm.com" <linux390@de.ibm.com>, Chris Metcalf <cmetcalf@tilera.com>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Nathan Lynch <Nathan_Lynch@mentor.com>, X86 ML <x86@kernel.org>, linux-arch <linux-arch@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "user-mode-linux-devel@lists.sourceforge.net" <user-mode-linux-devel@lists.sourceforge.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Jul 15, 2014 at 03:47:26PM +0100, Andy Lutomirski wrote:
> On Sun, Jul 13, 2014 at 1:01 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> > The core mm code will provide a default gate area based on
> > FIXADDR_USER_START and FIXADDR_USER_END if
> > !defined(__HAVE_ARCH_GATE_AREA) && defined(AT_SYSINFO_EHDR).
> >
> > This default is only useful for ia64.  arm64, ppc, s390, sh, tile,
> > 64-bit UML, and x86_32 have their own code just to disable it.  arm,
> > 32-bit UML, and x86_64 have gate areas, but they have their own
> > implementations.
> >
> > This gets rid of the default and moves the code into ia64.
> >
> > This should save some code on architectures without a gate area: it's
> > now possible to inline the gate_area functions in the default case.
> 
> Can one of you pull this somewhere?  Otherwise I can put it somewhere
> stable and ask for -next inclusion, but that seems like overkill for a
> single patch.

I'd be happy to take the arm64 part, but it doesn't feel right for mm/*
changes (or changes to other archs) to go via our tree.

I'm not sure what the best approach is if you want to send this via a single
tree. Maybe you could ask akpm nicely?

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
