Received: from snowcrash.cymru.net (snowcrash.cymru.net [163.164.160.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA23031
	for <linux-mm@kvack.org>; Sun, 24 Jan 1999 19:33:07 -0500
Message-Id: <m104ap4-0007U1C@the-village.bc.nu>
From: alan@lxorguk.ukuu.org.uk (Alan Cox)
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
Date: Mon, 25 Jan 1999 01:28:14 +0000 (GMT)
In-Reply-To: <Pine.LNX.3.95.990124162036.17000A-100000@penguin.transmeta.com> from "Linus Torvalds" at Jan 24, 99 04:21:26 pm
Content-Type: text
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linker@z.ml.org, alan@lxorguk.ukuu.org.uk, sct@redhat.com, werner@suse.de, andrea@e-mind.com, riel@humbolt.geo.uu.nl, Zlatko.Calusic@CARNet.hr, ebiederm+eric@ccr.net, saw@msu.ru, steve@netplus.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Sun, 24 Jan 1999, Gregory Maxwell wrote:
> > 
> > Do you really think "inability to handle large user spaces" or "inability
> > to find memory easily" are features? 
> 
> Alan is just full of it on both accounts.
> 
> We handle large user space with no problem, and we find free memory no
> problem.

Oh good, whats the configuration setting for a 4Gig Xeon box. I've got
people dying to know. So I'm not full of it.

Its not "inability to find memory easily" in my original comments either.
In context its about the expense sometimes of finding which things to swap.

Note that I don't disagree with Linus. Every time Linus can say "but you don't
need that because [sensible solution]" is a bigger win than adding a ton
of special case code.

Right now

o	I can't run 3Gig user processes on a 4Gig Xeon
o	I can't support devices needing large physically linear blocks of
	memory

#1 is happening today
#2 is happening a bit now - although its a lesser problem (unable to allocate
ISA DMA buffer..) thats the visible part of a bigger issue. Some people
don't bother with scatter gather DMA - real examples:
	S3 Sonic Vibes	- linux can't support its wavetable (wants 4Mb linear)
	Zoran based capture chips - physically linear capture/masks
	Matrox Meteor frame grabber - physically linear grabbing

So 2.3 needs to be able to allocate large linear physical spaces - not
neccessarily efficiently either. These are all occasional grabs of memory.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
