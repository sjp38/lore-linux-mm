Received: from chiara.csoma.elte.hu (chiara.csoma.elte.hu [157.181.71.18])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA12823
	for <linux-mm@kvack.org>; Tue, 26 Jan 1999 10:35:24 -0500
Date: Tue, 26 Jan 1999 16:21:30 +0100 (CET)
From: MOLNAR Ingo <mingo@chiara.csoma.elte.hu>
Reply-To: MOLNAR Ingo <mingo@chiara.csoma.elte.hu>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <199901261436.HAA01099@chelm.cs.nmt.edu>
Message-ID: <Pine.LNX.3.96.990126161041.11981C-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: yodaiken@chelm.cs.nmt.edu
Cc: alan@lxorguk.ukuu.org.uk, sct@redhat.com, groudier@club-internet.fr, torvalds@transmeta.com, werner@suse.de, andrea@e-mind.com, riel@humbolt.geo.uu.nl, Zlatko.Calusic@CARNet.hr, ebiederm+eric@ccr.net, saw@msu.ru, steve@netplus.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 26 Jan 1999 yodaiken@chelm.cs.nmt.edu wrote:

> What's the benefit?  If you need big chunks of physical memory, then you
> obviously are willing to sacrifice efficient use of every last byte. 

no, what i want to have is support for on-demand shared-physical-memory
hardware. Resource management. Alan has listed a few examples, and the
list is not expected to get smaller. You are right, if we want to have big
chunks of physical memory then we'll allocate it on reboot.

i dont think it's correct to say: 'anything that cannot be segmented in
the physical memory space with page granularity, is considered to be
broken in this regard and is not guaranteed to be 100% supported by the
Linux architecture'. 

> > yes it restricts and complicates the way kernel subsystems can allocate
> > buffers, but we _have_ to do that iff we want to solve the problem 100%.
> 
> So for that last 10% of "solve" we introduce a lot of complexity into 
> every subsystem?

no, as i pointed it out:

> Also, it must have only very limited 'subsystem-side' complexity to not
> hinder development. [...]

plus, i'd like to point out that if we do something, we preferredly want
to do it 100% correct, especially if the 'packet loss' is visible by
user-space as well. But i'm not at all requesting it: 

> the toughest part is the 'moving' stuff, which is not yet present and
> hard/impossible to implement in a clean and maintainable way.
       ^^^^^^^^^^---(this might as well be the case)

-- mingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
