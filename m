Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA23970
	for <linux-mm@kvack.org>; Fri, 22 Jan 1999 08:55:41 -0500
Date: Fri, 22 Jan 1999 13:55:03 GMT
Message-Id: <199901221355.NAA04246@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <Pine.LNX.3.96.990121204645.1387F-100000@laser.bogus>
References: <199901211650.QAA04674@dax.scot.redhat.com>
	<Pine.LNX.3.96.990121204645.1387F-100000@laser.bogus>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Dr. Werner Fink" <werner@suse.de>, Rik van Riel <riel@humbolt.geo.uu.nl>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Linus Torvalds <torvalds@transmeta.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Savochkin Andrey Vladimirovich <saw@msu.ru>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 21 Jan 1999 20:53:28 +0100 (CET), Andrea Arcangeli
<andrea@e-mind.com> said:

> Yes we do I/O async so while the I/O is in action we could be just back in
> userspace, but both shrink_mmap() and swap_out() are not something of
> really so light (at least with >128Mbyte of ram). When we are running in
> shrink_mmap() the current->counter is decreased as usual.

If shrink_mmap() can exhaust the timeslice while we are swapping (ie. we
are IO-bound), then something is *SERIOUSLY* wrong!

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
