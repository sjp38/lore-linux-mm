Received: from caffeine.ix.net.nz (caffeine.ix.net.nz [203.97.100.28])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA28563
	for <linux-mm@kvack.org>; Thu, 25 Jun 1998 17:25:52 -0400
Message-ID: <19980626092430.C2759@caffeine.ix.net.nz>
Date: Fri, 26 Jun 1998 09:24:30 +1200
From: Chris Wedgwood <chris@cybernet.co.nz>
Subject: Re: Thread implementations...
References: <m1u35a4fz8.fsf@flinx.npwt.net> <Pine.LNX.3.96dg4.980624210745.18727h-100000@twinlark.arctic.org> <199806250353.NAA17617@vindaloo.atnf.CSIRO.AU> <199806251132.MAA00848@dax.dcs.ed.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <199806251132.MAA00848@dax.dcs.ed.ac.uk>; from Stephen C. Tweedie on Thu, Jun 25, 1998 at 12:32:35PM +0100
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, Richard Gooch <Richard.Gooch@atnf.CSIRO.AU>
Cc: Dean Gaudet <dgaudet-list-linux-kernel@arctic.org>, "Eric W. Biederman" <ebiederm+eric@npwt.net>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Not necessarily; we may be able to detect a lot of the relevant access
> patterns ourselves.  Ingo has had a swap prediction algorithm for a
> while, and we talked at Usenix about a number of other things we can do
> to tune vm performance automatically.  2.3 ought to be a great deal
> better.  madvise() may still have merit, but we really ought to be
> aiming at making the vm system as self-tuning as possible.

madvise(2) will _always_ have some uses.

Large database applications and stuff can know in advance how to tune mmap
regions and stuff. The kernel will always be second guessing here, and
making sub optimal decisions, whereas the application can and probably does
know better.

The same argument also applies to raw devices (but lets not start that
thread again).



-Chris
