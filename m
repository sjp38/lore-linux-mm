Date: Thu, 26 Apr 2001 18:16:06 +0200 (MET DST)
From: Szabolcs Szakacsits <szaka@f-secure.com>
Subject: Re: Want to allocate almost all the memory with no swap
In-Reply-To: <Pine.LNX.4.33.0104191450290.17635-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.30.0104261527100.16238-100000@fs131-224.f-secure.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Simon Derr <Simon.Derr@imag.fr>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Apr 2001, Rik van Riel wrote:
> On Thu, 19 Apr 2001, Simon Derr wrote:
> > Actually this is what happens under 2.4.2 :
> > when I launch the program, during about one minute kswapd eats 50% cpu,
> > and bdflush takes 2-5% cpu,
> > One minute later approx, they both stop eating the cpu and my process gets
> > almost 100% of the cpu (a PIII 733).
> >
> > The same happens if I kill and launch my program a second time.
> >
> [...] Thanks for telling us.  It is good to know that kswapd
> exhibits this strange behaviour. It's admiteddly not a high
> priority thing to fix, but it IS something to keep in mind.

Apparently it's already fixed in ac kernels. Could the reduced number of
wakeup_kswapd() calls the reason?

	Szaka

---------- Forwarded message ----------
Date: Thu, 26 Apr 2001 13:49:56 +0200 (MEST)
From: Simon Derr <Simon.Derr@imag.fr>
To: Szabolcs Szakacsits <szaka@f-secure.com>
Subject: Re: Want to allocate almost all the memory with no swap

On Fri, 20 Apr 2001, Szabolcs Szakacsits wrote:

> Could you try Alan Cox's latest prekernel? It has VM related changes and
> your feedbeck could be valuable.
> ftp://ftp.fi.kernel.org/pub/linux/kernel/v2.4/
>
> And maybe 2.4.3? But Alan's would be more interesting because there are
> more significant modifications.
> ftp://ftp.kernel.org/pub/linux/kernel/people/alan/2.4/

Hi,

I'm sorry I had no time this week to do theses tests.
I can report this :

when allocating 240 megs of memory, and using
mlockall(MCL_CURRENT|MCL_FUTURE)
on a 256Megs RAM machine :

Under Linux 2.4.2: kswapd eats half of the CPU. A few times it did so
for a minute approximatively, and then my process got all the CPU. But
some other times kswapd has been taking the CPU much much longer (I did
not see the end, I stopped the test before)

Under Linux 2.4.3-ac9 : It works great !
kswapd does not eat the CPU at all (well, almost : I see it taking 0.1%
CPU during one second, but 'top' is not a very accurate measure tool)

        Simon.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
