Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA11011
	for <linux-mm@kvack.org>; Tue, 26 Jan 1999 08:11:33 -0500
Date: Tue, 26 Jan 1999 13:06:41 GMT
Message-Id: <199901261306.NAA16382@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <Pine.LNX.3.95.990125222327.726A-100000@localhost>
References: <m104azC-0007U1C@the-village.bc.nu>
	<Pine.LNX.3.95.990125222327.726A-100000@localhost>
Sender: owner-linux-mm@kvack.org
To: Gerard Roudier <groudier@club-internet.fr>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@transmeta.com>, sct@redhat.com, werner@suse.de, andrea@e-mind.com, riel@humbolt.geo.uu.nl, Zlatko.Calusic@CARNet.hr, ebiederm+eric@ccr.net, saw@msu.ru, steve@netplus.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 25 Jan 1999 22:59:00 +0100 (MET), Gerard Roudier
<groudier@club-internet.fr> said:

> If you tell me that some system XXX is able to quickly free Mega-Bytes of
> physical contiguous memory at any time when it is asked for such a
> brain-deaded allocation, then for sure, I will never use system XXX,
> because this magic behaviour seems not to be possible without some
> paranoid VM policy that may affect badly performances for normal stuff.

It is really not hard to reserve a certain amount of memory (up to some
fraction, say 25% or 50% of physical memory) for use only by pagable
allocations.  Most desktop boxes will _not_ require more than 50% of
memory for locked kernel pages.  Recovering any given range of
contiguous pages from that pagable region may be expensive but will
_always_ be possible, and given that it will usually be a one-off
expense during driver setup, there is no reason why we cannot support
it.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
