Received: from clavin.efn.org (root@clavin.efn.org [206.163.176.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id AAA22454
	for <linux-mm@kvack.org>; Sun, 6 Dec 1998 00:24:00 -0500
From: Steve VanDevender <stevev@efn.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <13930.5333.536721.146489@tzadkiel.efn.org>
Date: Sat, 5 Dec 1998 21:23:33 -0800 (PST)
Subject: Re: [PATCH] swapin readahead and fixes
In-Reply-To: <m0zmMvm-0007U1C@the-village.bc.nu>
References: <Pine.LNX.3.96.981204214235.28282A-100000@mirkwood.dummy.home>
	<m0zmMvm-0007U1C@the-village.bc.nu>
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.rutgers.edu
Cc: H.H.vanRiel@phys.uu.nl, chris@ferret.lmh.ox.ac.uk, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

Alan Cox writes:
 > > I will compile a new patch (against 2.1.130 again, since
 > > 2.1.131 contains mostly VM mistakes that I want reversed)
 > > this weekend...
 > 
 > 2.1.131 is materially faster here than any of the variants I've tried. Are
 > you sure ?

I find 2.1.131 to be much better than its recent predecessors in
terms of reduced swap activity with the same set of applications
loaded (X, XEmacs, netscape).  Pages are staying in memory when
they used to be swapped in and out all the time.  Whatever
changed between 2.1.130 and 2.1.131 was hardly any sort of
mistake, as far as I'm concerned.
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
