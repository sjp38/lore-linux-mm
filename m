Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA20801
	for <linux-mm@kvack.org>; Wed, 13 Jan 1999 17:12:11 -0500
Date: Wed, 13 Jan 1999 22:11:47 GMT
Message-Id: <199901132211.WAA07405@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <Pine.LNX.3.96.990113160548.340A-100000@laser.bogus>
References: <Pine.LNX.3.96.990113135623.12654A-100000@ferret.lmh.ox.ac.uk>
	<Pine.LNX.3.96.990113160548.340A-100000@laser.bogus>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: Chris Evans <chris@ferret.lmh.ox.ac.uk>, Rik van Riel <riel@humbolt.geo.uu.nl>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Savochkin Andrey Vladimirovich <saw@msu.ru>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 13 Jan 1999 16:07:13 +0100 (CET), Andrea Arcangeli
<andrea@e-mind.com> said:

> On Wed, 13 Jan 1999, Chris Evans wrote:
>> Yes. Imagine the paging in of big binary case. The page faults will occur
>> all over the place, not in a nice sequential order. The page-in clusters
>> stuff _doubled_ performance of paging in certain big static binaries.

> I think that if it helped it means that the swap cache got shrunk too much
> early due a not good free paging algorithm.

Not in the slightest.  We're talking about the things like the
performance of starting up a fresh new copy of netscape.  Swapout has
nothing to do with it in that case: we are starting from a ground state
where the binary is completely uncached.  The clustered pagein has a
huge impact in that case.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
