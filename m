Received: from kiln.isn.net (root@kiln.isn.net [198.167.161.1])
	by kvack.org (8.8.7/8.8.7) with ESMTP id WAA24876
	for <linux-mm@kvack.org>; Sun, 24 Jan 1999 22:24:03 -0500
Message-ID: <36ABE22B.C7F0DA70@isn.net>
Date: Sun, 24 Jan 1999 23:16:59 -0400
From: "Garst R. Reese" <reese@isn.net>
MIME-Version: 1.0
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
References: <m104bU6-0007U1C@the-village.bc.nu>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Andrea Arcangeli <andrea@e-mind.com>, torvalds@transmeta.com, sct@redhat.com, werner@suse.de, riel@humbolt.geo.uu.nl, Zlatko.Calusic@CARNet.hr, ebiederm+eric@ccr.net, saw@msu.ru, steve@netplus.net, damonbrent@earthlink.net, kalle.andersson@mbox303.swipnet.se, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Alan Cox wrote:
> 
> > If I understand well the problem is get more than 1<<maxorder contiguos
> > phys pages in RAM. I think it should not too difficult to do a dirty hack
> 
> Yep. We are talking about 2->4Mb sized chunks. We are also talking about
> chunks that are allocated rarely - for example when you load wave data
> into the sound card, while you are capturing etc. So its blocks that
> can be slow to allocate, slow to free, so long as they are normal speed
> to access. That may make the problem a lot easier
How much of this problem can be solved with a ramfs that takes what you
give it at boot time?
-- 
Garst
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
