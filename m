Received: from funky.monkey.org (smtp@funky.monkey.org [152.160.231.196])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA17086
	for <linux-mm@kvack.org>; Tue, 6 Apr 1999 16:47:27 -0400
Date: Tue, 6 Apr 1999 16:47:23 -0400 (EDT)
From: Chuck Lever <cel@monkey.org>
Subject: Re: [patch] arca-vm-2.2.5
In-Reply-To: <Pine.LNX.4.05.9904061831340.394-100000@laser.random>
Message-ID: <Pine.BSF.4.03.9904061644370.3406-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Apr 1999, Andrea Arcangeli wrote:
> >i guess i'm confused then.  what good does this change do:
> 
> Hmm I think I misunderstood you point, Chuck. I thought you was
> complaining about the fact that some hash entry could be unused and other
> overloaded

yes, you understood correctly.

> but I was just assuming that the offset is always page-aligned.
> I could write a simulation to check the hash function...

i didn't realize that the "offset" argument would always be page-aligned.
but still, why does it help to add the unshifted "offset"?  doesn't seem
like there's any new information in that.

	- Chuck Lever
--
corporate:	<chuckl@netscape.com>
personal:	<chucklever@netscape.net> or <cel@monkey.org>

The Linux Scalability project:
	http://www.citi.umich.edu/projects/citi-netscape/

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
