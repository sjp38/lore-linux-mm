Received: from atrey.karlin.mff.cuni.cz (root@atrey.karlin.mff.cuni.cz [195.113.31.123])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA19933
	for <linux-mm@kvack.org>; Tue, 16 Dec 1997 12:08:59 -0500
Message-ID: <19971216145643.34360@Elf.mj.gts.cz>
Date: Tue, 16 Dec 1997 14:56:43 +0100
From: Pavel Machek <pavel@Elf.mj.gts.cz>
Subject: Re: Recipe for cooking 2.1.72's mm
References: <19971216091554.50382@Elf.mj.gts.cz> <Pine.LNX.3.91.971216124819.15838B-100000@mirkwood.dummy.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.3.91.971216124819.15838B-100000@mirkwood.dummy.home>; from Rik van Riel on Tue, Dec 16, 1997 at 12:53:36PM +0100
Sender: owner-linux-mm@kvack.org
To: H.H.vanRiel@fys.ruu.nl
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi!

> > Sorry. There is a problem. It needs to be solved, not worked
> > around. (Notice, that same process does nothing bad to 2.0.28).
> 
> On my system, it just gives one or two out-of-memory kills
> of random processes. I'd really like it if those processes
> would be a little less random... Killing kerneld or crond
> (or X... remember those poor stateless-vga-card users) is
> IMHO worse than killing a program from some USER. Finding
> the most hoggy non-root process group and killing some of
> it's programs shouldn't be too difficult.

Aha. So you were unsuccessfull while reproducing. On my system no
process dies, but whole system is dead.

> btw: I'm using 2.1.66 with my mmap-age patch...
> 
> > And: Work around is bad. Imagine your machine with such behaviour on
> > 100MBit ethernet. Imagine me around (ping -f)ing your machine. That
> > can keep your pages low for as long as I want. You do not your machine
> > to go yo-yo (up and down and up and down ...).
> 
> Ok, so we should limit the amount of memory the kernel can grab
> for internal usage... Sysctl-wise of course, because some people
> have special purpose routing machines.

It might be nice idea. I'm just afraid that for every limit, you find
situation in which limit _must_ be exceeded or action is impossible.

								Pavel

-- 
I'm really pavel@atrey.karlin.mff.cuni.cz. 	   Pavel
Look at http://atrey.karlin.mff.cuni.cz/~pavel/ ;-).
