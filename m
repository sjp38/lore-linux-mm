Received: from chelm.cs.nmt.edu (yodaiken@chelm.cs.nmt.edu [129.138.6.50])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA12249
	for <linux-mm@kvack.org>; Tue, 26 Jan 1999 09:50:49 -0500
From: yodaiken@chelm.cs.nmt.edu
Message-Id: <199901261436.HAA01099@chelm.cs.nmt.edu>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
Date: Tue, 26 Jan 1999 07:36:50 -0700 (MST)
In-Reply-To: <Pine.LNX.3.96.990126145544.11981B-100000@chiara.csoma.elte.hu> from "MOLNAR Ingo" at Jan 26, 99 03:15:04 pm
Content-Type: text
Sender: owner-linux-mm@kvack.org
To: MOLNAR Ingo <mingo@chiara.csoma.elte.hu>
Cc: alan@lxorguk.ukuu.org.uk, sct@redhat.com, groudier@club-internet.fr, torvalds@transmeta.com, werner@suse.de, andrea@e-mind.com, riel@humbolt.geo.uu.nl, Zlatko.Calusic@CARNet.hr, ebiederm+eric@ccr.net, saw@msu.ru, steve@netplus.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> On Tue, 26 Jan 1999, Alan Cox wrote:
> 
> > Something like
> > 
> > Chop memory into 4Mb sized chunks that hold the perfectly normal and
> > existing pages and buddy memory allocator. Set a flag on 25-33% of them
> > to a max of say 10 and for <12Mb boxes simply say "tough".
> 
> this is conceptually 'boot-time allocation of big buffers' by splitting
> all available memory into two pieces:
> 
> 	size_kernel: generic memory
> 	size_user: only swappable
> 
> (size_kernel+size_user = ca. size_allmemory)
> 
> This still doesnt solve the 'what if we need more big buffers than
> size_user' and 'what if we need kernel memory more than size_kernel'
> questions, and both are valid.

Solved by reboot.

> the toughest part is the 'moving' stuff, which is not yet present and
> hard/impossible to implement in a clean and maintainable way. We need this
> eg. for sockets, files, (not inodes fortunately), task structures, vmas,

What's the benefit?  If you need big chunks of physical memory, then you
obviously are willing to sacrifice efficient use of every last byte.

> yes it restricts and complicates the way kernel subsystems can allocate
> buffers, but we _have_ to do that iff we want to solve the problem 100%.

So for that last 10% of "solve" we introduce a lot of complexity into 
every subsystem?

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
