Received: from ferret.lmh.ox.ac.uk (ferret.lmh.ox.ac.uk [163.1.138.204])
	by kvack.org (8.8.7/8.8.7) with SMTP id PAA28408
	for <linux-mm@kvack.org>; Thu, 27 Nov 1997 15:04:43 -0500
Date: Thu, 27 Nov 1997 18:56:47 +0000 (GMT)
From: Chris Evans <chris@ferret.lmh.ox.ac.uk>
Subject: Re: pageable page tables
In-Reply-To: <m0xb8bB-0005FsC@lightning.swansea.linux.org.uk>
Message-ID: <Pine.LNX.3.95.971127185458.8930A-100000@ferret.lmh.ox.ac.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Rik van Riel <H.H.vanRiel@fys.ruu.nl>, joel@tux.org, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


On Thu, 27 Nov 1997, Alan Cox wrote:

> > Then we would also need per-user accounting...
> > All-in-all however it's a very good idea.
> > 
> > (linux-kernel guys, would this break compatibility/POSIX or
> > whatever thing)
> 
> No it wouldnt.. There - something for you to hack 8)

Perhaps more importantly, _before_ per user stuff is defined then
implemented, the existing RLIMIT_* should be verified for correctness, and
checks made that these limits can't be circumvented.

In particular, RLIMIT_RSS is not implemented. Setting such a limit,
however, fails silently.

Chris
