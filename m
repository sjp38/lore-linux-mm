Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id XAA25492
	for <linux-mm@kvack.org>; Sun, 24 Jan 1999 23:22:42 -0500
Date: Sun, 24 Jan 1999 20:17:07 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <m104ap4-0007U1C@the-village.bc.nu>
Message-ID: <Pine.LNX.3.95.990124201339.17000L-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: linker@z.ml.org, sct@redhat.com, werner@suse.de, andrea@e-mind.com, riel@humbolt.geo.uu.nl, Zlatko.Calusic@CARNet.hr, ebiederm+eric@ccr.net, saw@msu.ru, steve@netplus.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 25 Jan 1999, Alan Cox wrote:
> 
> Oh good, whats the configuration setting for a 4Gig Xeon box. I've got
> people dying to know. So I'm not full of it.

Oh, the answer is very simple: it's not going to happen.

EVER.

You need more that 32 bits of address space to handle that kind of memory. 
This is not something I'm going to discuss further. If people want to use
more than 2GB of memory, they have exactly two options with Linux: 

 - get a machine with reasonable address spaces. Right now that's either
   alpha or sparc64, in the not too distant future it will be merced.
 - use the extra memory as a ram-disk (possibly memory-mappable, but even
   that I consider unlikely)

This is not negotiable.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
