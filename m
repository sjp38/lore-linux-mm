Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA32060
	for <linux-mm@kvack.org>; Mon, 25 Jan 1999 11:53:15 -0500
Date: Mon, 25 Jan 1999 17:52:01 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <199901251625.QAA04452@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.990125174314.616B-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, werner@suse.de, riel@humbolt.geo.uu.nl, Zlatko.Calusic@CARNet.hr, ebiederm+eric@ccr.net, saw@msu.ru, steve@netplus.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Jan 1999, Stephen C. Tweedie wrote:

> Nevertheless, the 2.2.0-pre9 VM sucks.  I've been getting seriously
> frustrated at pre-9's interactive feel over the past few days.

Just for curiosity, did you tried my latest
ftp://e-mind.com/pub/linux/arca-tree/2.2.0-pre9_arca-2.gz ?

I would like if you would apply it, recompile and reboot and see how it
feels. You should not waste more than 5/10 minutes to do that.

> Linus, there really are fundamental problems remaining in the VM in
> 2.2.0-pre right now.  The two biggest are the lack of responsiveness
> of kswapd and a general misbalance in the cache management.

kswapd is not an issue. kswapd has nothing to do with performances. Feel
free to change kswapd rating as you want to see with your eyes.

The _problem_ of pre9 is try_to_free_pages(). I just posted a patch that I
think could help (note never tried such patch myself though).

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
