Subject: Re: 2.5.65-mm1
References: <20030318031104.13fb34cc.akpm@digeo.com>
	<87adfs4sqk.fsf@lapper.ihatent.com>
	<87bs08vfkg.fsf@lapper.ihatent.com>
	<20030318160902.C21945@flint.arm.linux.org.uk>
	<873clkw6ui.fsf@lapper.ihatent.com>
	<20030318162601.78f11739.akpm@digeo.com>
From: Alexander Hoogerhuis <alexh@ihatent.com>
Date: 19 Mar 2003 09:20:11 +0100
In-Reply-To: <20030318162601.78f11739.akpm@digeo.com>
Message-ID: <87fzpjpy2s.fsf@lapper.ihatent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: rmk@arm.linux.org.uk, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@digeo.com> writes:

> Alexander Hoogerhuis <alexh@ihatent.com> wrote:
> >
> > I'm not suspecting the PCI in particular for the PCIC-bits, only
> > making X and the Radeon work again. But here you are:
> 
> Something bad has happened to the Radeon driver in recent kernels.  I've seen
> various reports with various syptoms and some suspicion has been directed at
> the AGP changes.
> 
> But as far as I know nobody has actually got down and done the binary search
> to find out exactly when it started happening.

The best I've narrowed it down to is whatever makes 2.5.64-mm1 be
different from plain 2.5.64 and 2.5.64-mm2. In addition, I have one
more gripe, and this one is present in 2.4 too, but seems kernel
related:

When closing Gnome (Gnome 2.x, Gentoo), after the screen has been
"faded" by the logout applet, on the first keystroke or movement of
the mouse the machine will instantly cold start the machine.

mvh,
A
-- 
Alexander Hoogerhuis                               | alexh@ihatent.com
CCNP - CCDP - MCNE - CCSE                          | +47 908 21 485
"You have zero privacy anyway. Get over it."  --Scott McNealy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
