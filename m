Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA13719
	for <linux-mm@kvack.org>; Tue, 26 Jan 1999 11:45:55 -0500
Date: Tue, 26 Jan 1999 16:45:44 GMT
Message-Id: <199901261645.QAA03883@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <m105Ah6-0007U1C@the-village.bc.nu>
References: <199901261436.HAA01099@chelm.cs.nmt.edu>
	<m105Ah6-0007U1C@the-village.bc.nu>
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: yodaiken@chelm.cs.nmt.edu, mingo@chiara.csoma.elte.hu, sct@redhat.com, groudier@club-internet.fr, torvalds@transmeta.com, werner@suse.de, andrea@e-mind.com, riel@humbolt.geo.uu.nl, Zlatko.Calusic@CARNet.hr, ebiederm+eric@ccr.net, saw@msu.ru, steve@netplus.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 26 Jan 1999 15:46:23 +0000 (GMT), alan@lxorguk.ukuu.org.uk (Alan
Cox) said:
> We don't need to solve the 100% case. Simply being sure we can (slowly)
> allocate up to 25% of RAM in huge chunks is going to be enough. Good point
> Ingo on one thing I'd missed - the big chunks themselves need some kind
> of handles since the moment we hand out 512K chunks we may not be able to 
> shuffle and get a 4Mb block

The idea was to decide what region to hand out, _then_ to clear it.
Standard best-fit algorithms apply when carving up the region.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
