Received: from localhost.localdomain (groudier@ppp-164-85.villette.club-internet.fr [195.36.164.85])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA02955
	for <linux-mm@kvack.org>; Mon, 25 Jan 1999 16:59:15 -0500
Date: Mon, 25 Jan 1999 22:59:00 +0100 (MET)
From: Gerard Roudier <groudier@club-internet.fr>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <m104azC-0007U1C@the-village.bc.nu>
Message-ID: <Pine.LNX.3.95.990125222327.726A-100000@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Linus Torvalds <torvalds@transmeta.com>, sct@redhat.com, werner@suse.de, andrea@e-mind.com, riel@humbolt.geo.uu.nl, Zlatko.Calusic@CARNet.hr, ebiederm+eric@ccr.net, saw@msu.ru, steve@netplus.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Jan 1999, Alan Cox wrote:

> > > There are real cases where grab large linear block is needed.
> > 
> > Nobody has so far shown a reasonable implementation where this would be
> > possible.
> 
> Thats as maybe. However someone needs to find a way to do it. Right now I
> can run a matrox meteor on netbsd,freebsd,openbsd,windows95, nt but not Linux

I donnot know of all these systems, but, AFAIR, FreeBSD does not guarantee
the malloc_contig() function will succeed every time, after the system has
been started (obviously for allocation > PAGE_SIZE).

If you tell me that some system XXX is able to quickly free Mega-Bytes of
physical contiguous memory at any time when it is asked for such a
brain-deaded allocation, then for sure, I will never use system XXX,
because this magic behaviour seems not to be possible without some
paranoid VM policy that may affect badly performances for normal stuff.

Now, I agree that it is theorically possible to free a large contiguous
physical memory on most systems at any time, by flushing caches and moving
virtual pages that are only virtually referenced and this move will not
changes their virtual reference(s).

> Thats not meant as a flippant remark - its something to be stuck on the 2.3
> problem chart. Its just a question of who out there is sitting on the 
> solution.

Anything that requires more that 1 PAGE of physical memory at a time on
running systems is a very bad thing in my opinion. The PAGE is the only
required granularity of physical memory you should need on a virtual
memory system. If you ever need more, then you break simplicity and go
straight-away to complexity and cross-fingered behaviours. The only
exception is at system start-up, where it is still time for pooling 
every-thing that needs so. I am not going to change my mind on this topic
and I donnot care of crappy 'Designed for Windows' things.

Regards,
   Gerard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
