Date: Tue, 1 Jan 2008 23:41:33 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [patch] mm: fix PageUptodate memory ordering bug
Message-ID: <20080101234133.4a744329@the-village.bc.nu>
In-Reply-To: <alpine.LFD.0.9999.0712230900310.21557@woody.linux-foundation.org>
References: <20071218012632.GA23110@wotan.suse.de>
	<20071222005737.2675c33b.akpm@linux-foundation.org>
	<20071223055730.GA29288@wotan.suse.de>
	<20071222223234.7f0fbd8a.akpm@linux-foundation.org>
	<20071223071529.GC29288@wotan.suse.de>
	<alpine.LFD.0.9999.0712230900310.21557@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Sun, 23 Dec 2007 09:22:17 -0800 (PST)
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> 
> 
> On Sun, 23 Dec 2007, Nick Piggin wrote:
> > 
> > It's not actually increasing size by that much here... hmm, do you have
> > CONFIG_X86_PPRO_FENCE defined, by any chance?
> > 
> > It looks like this gets defined by default for i386, and also probably for
> > distro configs. Linus? This is a fairly heavy hammer for such an unlikely bug on
> > such a small number of systems (that admittedly doesn't even fix the bug in all
> > cases anyway). It's not only heavy for my proposed patch, but it also halves the
> > speed of spinlocks. Can we have some special config option for this instead? 
> 
> A special config option isn't great, since vendors would probably then 
> enable it for those old P6's.
> 
> But maybe an "alternative()" thing that depends on a CPU capability?
> Of course, it definitely *is* true that the number of CPU's that have that 
> bug _and_ are actually used in SMP environments is probably vanishingly 
> small. So maybe even vendors don't really care any more, and we could make 
> the PPRO_FENCE thing a thing of the past.

If the PPro fencing isn't built for SMP kernels for set for CPU of
Pentium II or greater then nobody is going to care. The only reasons to
build distro support for older processors is

	-	VIA C3/C5 to work around the gcc 686 cmov bug
	-	Geode (embedded and OLPC)

neither of which are exactly multiprocessor, and the VIA stuff can be
handled by beating up the gcc options. I also doubt PPro will be terribly
high on anyones enterprise product line list for the next generation of
enterprise distributions.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
