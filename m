Received: by qb-out-0506.google.com with SMTP id e21so363453qba.0
        for <linux-mm@kvack.org>; Fri, 18 Apr 2008 08:02:53 -0700 (PDT)
Message-ID: <19f34abd0804180747i244c483flf8421f42a330c519@mail.gmail.com>
Date: Fri, 18 Apr 2008 16:47:17 +0200
From: "Vegard Nossum" <vegard.nossum@gmail.com>
Subject: Re: 2.6.25-mm1: not looking good
In-Reply-To: <4808A1C7.7000907@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080417160331.b4729f0c.akpm@linux-foundation.org>
	 <20080417171413.6f8458e4.akpm@linux-foundation.org>
	 <48080FE7.1070400@windriver.com> <20080418073732.GA22724@elte.hu>
	 <19f34abd0804180446u2d6f17damf391a8c0584358b8@mail.gmail.com>
	 <20080418123439.GA17013@elte.hu>
	 <19f34abd0804180541l7b4d14a6tb13bdd51dd533d70@mail.gmail.com>
	 <48089BCA.1090704@windriver.com>
	 <19f34abd0804180622l4f89191cp4cc7833822e058f5@mail.gmail.com>
	 <4808A1C7.7000907@windriver.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jason Wessel <jason.wessel@windriver.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, tglx@linutronix.de, penberg@cs.helsinki.fi, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jmorris@namei.org, sds@tycho.nsa.gov
List-ID: <linux-mm.kvack.org>

On 4/18/08, Jason Wessel <jason.wessel@windriver.com> wrote:
> Vegard Nossum wrote:
> > On Fri, Apr 18, 2008 at 3:02 PM, Jason Wessel
> > <jason.wessel@windriver.com> wrote:
> >
> >> Vegard Nossum wrote:
> >>  > On Fri, Apr 18, 2008 at 2:34 PM, Ingo Molnar <mingo@elte.hu> wrote:
> >>  >
> >>  >>  * Vegard Nossum <vegard.nossum@gmail.com> wrote:
> >>  >>
> >>  >>  > With the patch below, it seems 100% reproducible to me (7 out of 7
> >>  >>  > bootups hung).
> >>  >>  >
> >>  >>  > The number of loops it could do before hanging were, in order:
> 697,
> >>  >>  > 898, 237, 55, 45, 92, 59
> >>  >>
> >>  >>  cool! Jason: i think that particular self-test should be repeated
> 1000
> >>  >>  times before reporting success ;-)
> >>  >>
> >>  >
> >>  > BTW, I just tested a 32-bit config and it hung after 55 iterations as
> well.
> >>  >
> >>  > Vegard
> >>  >
> >>  >
> >>  >
> >>  I assume this was SMP?
> >>
> >
> > Yes. But now that I realize this, I tried running same kernel with
> > qemu, using -smp 16, and it seems to be stuck here:
> >
> >
>
> Unless you have a qemu with the NMI patches, kgdb does not work on SMP
> with qemu.  The very first test is going to fail because the IPI sent by
> the kernel is not handled in qemu's hardware emulation.

Oops, no, and that makes sense.

I now picked up qemu 0.9.1 and applied the three NMI/SMI patches by Jan Kiszka.

So in qemu it seems to run fine now, except that I need to prod it
sometimes (it gets stuck in cpu_clock() and I have to break/continue
from gdb to make it proceed). Oh, there it made it to 1056, and gdb
can't interrupt anymore. Hmm. This is probably not a very good
testing/debugging environment if the qemu support is that bad. Sorry
:-)

But booting with nosmp on real hardware gets easily above 100,000
iterations of the loop (before I reboot), so it seems to be related to
that, anyway.

Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
