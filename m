Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA23499
	for <linux-mm@kvack.org>; Sun, 24 Jan 1999 20:04:55 -0500
Date: Mon, 25 Jan 1999 02:04:59 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <m104azC-0007U1C@the-village.bc.nu>
Message-ID: <Pine.LNX.3.96.990125015519.19018A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Linus Torvalds <torvalds@transmeta.com>, sct@redhat.com, werner@suse.de, riel@humbolt.geo.uu.nl, Zlatko.Calusic@CARNet.hr, ebiederm+eric@ccr.net, saw@msu.ru, steve@netplus.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Jan 1999, Alan Cox wrote:

> Thats as maybe. However someone needs to find a way to do it. Right now I
> can run a matrox meteor on netbsd,freebsd,openbsd,windows95, nt but not Linux

If I understand well the problem is get more than 1<<maxorder contiguos
phys pages in RAM. I think it should not too difficult to do a dirty hack
to have such contiguos RAM without wait for 2.[34]. I could implement a
alternate __get_big_pages that does some try to get many mem-areas of the
maximal order contigous. Maybe it will not able to give you such contiguos
memory (due mem fragmentation) but if it's possible it will give back it
to you (_slowly_). Then you should use an aware free_big_pages() to give
back the memory. That way the codebase (for people that doesn't need
__get_big_pages in their device drivers) will be untouched (so no codebase
stability issues). 

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
