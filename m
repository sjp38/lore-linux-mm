Received: from chelm.cs.nmt.edu (yodaiken@chelm.cs.nmt.edu [129.138.6.50])
	by kvack.org (8.8.7/8.8.7) with ESMTP id CAA29045
	for <linux-mm@kvack.org>; Sat, 30 Jan 1999 02:14:43 -0500
From: yodaiken@chelm.cs.nmt.edu
Message-Id: <199901300701.AAA08206@chelm.cs.nmt.edu>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
Date: Sat, 30 Jan 1999 00:01:00 -0700 (MST)
In-Reply-To: <199901261645.QAA03883@dax.scot.redhat.com> from "Stephen C. Tweedie" at Jan 26, 99 04:45:44 pm
Content-Type: text
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: alan@lxorguk.ukuu.org.uk, mingo@chiara.csoma.elte.hu, groudier@club-internet.fr, torvalds@transmeta.com, werner@suse.de, andrea@e-mind.com, riel@humbolt.geo.uu.nl, Zlatko.Calusic@CARNet.hr, ebiederm+eric@ccr.net, saw@msu.ru, steve@netplus.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> Hi,
> 
> On Tue, 26 Jan 1999 15:46:23 +0000 (GMT), alan@lxorguk.ukuu.org.uk (Alan
> Cox) said:
> > We don't need to solve the 100% case. Simply being sure we can (slowly)
> > allocate up to 25% of RAM in huge chunks is going to be enough. Good point
> > Ingo on one thing I'd missed - the big chunks themselves need some kind
> > of handles since the moment we hand out 512K chunks we may not be able to 
> > shuffle and get a 4Mb block
> 
> The idea was to decide what region to hand out, _then_ to clear it.
> Standard best-fit algorithms apply when carving up the region.

If clearing involves remapping kernel address space, then its a rather
complex process. 
              kmalloc
              give virt_to_bus to device
              ...
              remap 



--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
