Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id BAA14808
	for <linux-mm@kvack.org>; Wed, 13 Jan 1999 01:52:27 -0500
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
References: <Pine.LNX.4.03.9901122245090.4656-100000@mirkwood.dummy.home>
Reply-To: Zlatko.Calusic@CARNet.hr
MIME-Version: 1.0
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 13 Jan 1999 07:52:09 +0100
In-Reply-To: Rik van Riel's message of "Tue, 12 Jan 1999 22:46:08 +0100 (CET)"
Message-ID: <877lurbr6u.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@humbolt.geo.uu.nl>
Cc: Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Savochkin Andrey Vladimirovich <saw@msu.ru>, Andrea Arcangeli <andrea@e-mind.com>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@humbolt.geo.uu.nl> writes:

> On 12 Jan 1999, Zlatko Calusic wrote:
> 
> > After number of async pages gets bigger than
> > pager_daemon.swap_cluster (= SWAP_CLUSTER_MAX), swapin readahead
> > becomes synchronous, and that hurts performance. It is better to
> > skip readahead in such situations, and that is also more fair to
> > swapout. Andrea came to exactly the same conclusion, independent
> > of me (on the same day :)).
> 
> IIRC this facility was in the original swapin readahead
> implementation. That only leaves the question who removed
> it and why :))
> 

*I* did, because original test was too complicated and nobody
understood what was it actual purpose.

Beside that, when MM code changed recently, nr_free_pages started
hovering at lower values, and that was killing readahead at most cases
(with old test in place), thus producing terrible results, especially
when you had more than one thrashing task.

-- 
Zlatko
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
