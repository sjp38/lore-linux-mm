Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA07506
	for <linux-mm@kvack.org>; Mon, 2 Mar 1998 18:21:53 -0500
Date: Tue, 3 Mar 1998 00:14:43 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: Fairness in love and swapping
In-Reply-To: <199803022235.WAA03546@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.91.980303001242.3788D-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: "Dr. Werner Fink" <werner@suse.de>, torvalds@transmeta.com, nahshon@actcom.co.il, alan@lxorguk.ukuu.org.uk, paubert@iram.es, mingo@chiara.csoma.elte.hu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2 Mar 1998, Stephen C. Tweedie wrote:

> a) the kernel likes to keep reclaiming pages from a single source if
> it is finding it easy to locate unused pages there, so when it starts
> on the page cache it _can_ get over zealous in reaping those pages;
> and

Correction: It _will_ get over zealous in reaping those pages.

> b) starting to find free pages from swap is inherently difficult due
> to the initial age placed on pages.
> 
> I rather suspect with those patches that it's not simply the aging of
> page cache pages which helps performance, but also the tuning of the
> balance between page cache and data page reclamation.

That's why I proposed the true LRU aging on those pages,
so they get a better chance of (re)usal before they're
really freed and forgotten about (and need to be reread
in the case of readahead pages).

I might be working on this RSN.

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
