Received: from snowcrash.cymru.net (snowcrash.cymru.net [163.164.160.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA20206
	for <linux-mm@kvack.org>; Sun, 24 Jan 1999 14:38:46 -0500
Message-Id: <m104WE3-0007U1C@the-village.bc.nu>
From: alan@lxorguk.ukuu.org.uk (Alan Cox)
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
Date: Sun, 24 Jan 1999 20:33:42 +0000 (GMT)
In-Reply-To: <Pine.LNX.3.95.990123161758.12138B-100000@penguin.transmeta.com> from "Linus Torvalds" at Jan 23, 99 04:19:13 pm
Content-Type: text
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: alan@lxorguk.ukuu.org.uk, sct@redhat.com, werner@suse.de, andrea@e-mind.com, riel@humbolt.geo.uu.nl, Zlatko.Calusic@CARNet.hr, ebiederm+eric@ccr.net, saw@msu.ru, steve@netplus.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Sat, 23 Jan 1999, Alan Cox wrote:
> > 
> > Thats a bug in our current vm structures, like the others - inability to
> > throw out page tables, inability to find memory easily, inability to move
> > blocks to allocate large areas in a target space, inability to handle
> > large user spaces etc.
> 
> What? None of those are bugs, they are features.
> 
> Complexity is not a goal to be reached. Complexity is something to be
> avoided at all cost. If you don't believe me, look at NT.

A feature becomes a bug at the point it becomes a problem. Right now there
is a continual background DMA rumbling. That one at least needs solving.

Being able to throw out page tables is something that is going to be needed
too. As far as I can see that does not mean complexity. The Linux VM is
very clean in its page handling, there is almost nothing in the page tables
that cannot be flushed or dumped to disk if need be.

There are real cases where grab large linear block is needed. Sadly the
fact that NT and 98 support it will make this more not less common. The
current PCI soundcards like the S3 SonicVibes aren't easily supportable
in Linux because they require a 4Mb linear block. The Zoran video capture
chipset (Trust, Iomega, and others) needs large linear blocks. Even I2O
wants 32/64K linear chunks and thats designed to be "OS independant"

Its on my "please for 2.3" list not because the linear block problem is an
elegance issue but because people are baning their heads on it. The large
physical memory problem is there because people are already hitting it.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
