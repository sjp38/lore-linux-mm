Date: Mon, 7 Feb 2000 17:01:36 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: 2.2.x Memory subsystem questions
In-Reply-To: <Pine.LNX.4.21.0002070127370.3971-100000@alpha.random>
Message-ID: <Pine.LNX.4.10.10002071654320.9296-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Mike Panetta <mpanetta@realminfo.com>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

die, please remove linux-kernel from the CC: list]

On Mon, 7 Feb 2000, Andrea Arcangeli wrote:
> On Wed, 19 Jan 2000, Mike Panetta wrote:
> 
> >Is there any way to get the 2.2.x kernels to have memory subsystem
> >performance similer to the 2.0.x kernels in low memory situations?
> 
> You may want to try this patch on the top of 2.2.14:
> 
> 	ftp://ftp.*.kernel.org/pub/linux/kernel/people/andrea/kernels/v2.2/2.2.14aa6.gz
> 
> The system should stop to swapout then. After that you probably
> also want to tune by hand the VM checking the performance
> difference after executing something like this:
> 
> 	echo 10 > /proc/sys/vm/pagecache
> 	echo 10 > /proc/sys/vm/buffermem

I know I introduced the pagecache and buffermem code in 2.1,
but since then people have given me very convincing arguments
as to why MM code based on magical numbers should die Die DIE!

The problem with poor VM performance in 2.2 is that the kernel
keeps the amount of unmapped swap cache and page cache pages
to a minimum so it won't get the chance to do proper page
aging. Because of this it regularly makes poor choices about
which page to evict from memory.

2.2.15pre5 (and pre4) contains a patch by me which fixes that
behaviour (somewhat) and which also makes VM behaviour a
little "smoother". There is still room for improvement and
if it is deemed necessary I'll happily perform some more
non-intrusive surgery on 2.2 to get performance to what it
should be.

For 2.3 I'm also busy trying to get performance up to par.
I've got a few patches ready on my home page, but I won't
submit them to Linus yet because Ben LaHaise has some good
stuff pending and I'll wait for that...

	http://www.surriel.com/patches/

cheers,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
