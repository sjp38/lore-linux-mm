Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA12721
	for <linux-mm@kvack.org>; Tue, 12 Jan 1999 19:18:52 -0500
Date: Tue, 12 Jan 1999 22:46:08 +0100 (CET)
From: Rik van Riel <riel@humbolt.geo.uu.nl>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <87d84kl49u.fsf@atlas.CARNet.hr>
Message-ID: <Pine.LNX.4.03.9901122245090.4656-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Cc: Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Savochkin Andrey Vladimirovich <saw@msu.ru>, Andrea Arcangeli <andrea@e-mind.com>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 12 Jan 1999, Zlatko Calusic wrote:

> After number of async pages gets bigger than
> pager_daemon.swap_cluster (= SWAP_CLUSTER_MAX), swapin readahead
> becomes synchronous, and that hurts performance. It is better to
> skip readahead in such situations, and that is also more fair to
> swapout. Andrea came to exactly the same conclusion, independent
> of me (on the same day :)).

IIRC this facility was in the original swapin readahead
implementation. That only leaves the question who removed
it and why :))

cheers,

Rik -- If a Microsoft product fails, who do you sue?
+-------------------------------------------------------------------+
| Linux memory management tour guide.        riel@humbolt.geo.uu.nl |
| Scouting Vries cubscout leader.    http://humbolt.geo.uu.nl/~riel |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
