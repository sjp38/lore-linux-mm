Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA31069
	for <linux-mm@kvack.org>; Mon, 25 Jan 1999 10:24:02 -0500
Date: Mon, 25 Jan 1999 15:06:17 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <m104bU6-0007U1C@the-village.bc.nu>
Message-ID: <Pine.LNX.4.03.9901251502250.247-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Andrea Arcangeli <andrea@e-mind.com>, Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>, "Dr. Werner Fink" <werner@suse.de>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, ebiederm+eric@ccr.net, saw@msu.ru, bredelin@ucsd.edu, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 25 Jan 1999, Alan Cox wrote:

> > If I understand well the problem is get more than 1<<maxorder contiguos
> > phys pages in RAM. I think it should not too difficult to do a dirty hack
> 
> Yep. We are talking about 2->4Mb sized chunks. We are also talking about
> chunks that are allocated rarely 

> > alternate __get_big_pages that does some try to get many mem-areas of the
> > maximal order contigous. Maybe it will not able to give you such contiguos
> > memory (due mem fragmentation) but if it's possible it will give back it
> > to you (_slowly_).
> 
> That fact we effectively "poison" the various blocks of memory
> with locked down kernel objects is what makes this so tricky. It
> really needs some back pressure applied so that kernel allocations
> come from a limited number of maxorder blocks, at least except
> under exceptional circumstances.

We need a different memory allocator for that. Maybe it's
time to dig up my zone allocator proposal (on my home page)
and adapt it to something working.

Unfortunately I don't have the time to do that, so I'll
leave the job to Alan or Stephen (who should have the time
since they're with Red Hat)...

> I think its too tricky for 2.2 even as a later retrofit

Once the allocator is ready and stabilized, we might be
able to retrofit it to 2.2. It's just a single module
we need to touch...

cheers,

Rik -- If a Microsoft product fails, who do you sue?
+-------------------------------------------------------------------+
| Linux memory management tour guide.             riel@nl.linux.org |
| Scouting Vries cubscout leader.     http://www.nl.linux.org/~riel |
+-------------------------------------------------------------------+

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
