Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA20620
	for <linux-mm@kvack.org>; Thu, 26 Feb 1998 14:34:39 -0500
Date: Thu, 26 Feb 1998 20:32:09 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: Fairness in love and swapping
In-Reply-To: <199802261857.TAA13144@boole.fs100.suse.de>
Message-ID: <Pine.LNX.3.91.980226203000.5590B-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Dr. Werner Fink" <werner@suse.de>
Cc: sct@dcs.ed.ac.uk, torvalds@transmeta.com, nahshon@actcom.co.il, alan@lxorguk.ukuu.org.uk, paubert@iram.es, mingo@chiara.csoma.elte.hu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 26 Feb 1998, Dr. Werner Fink wrote:

> > Without my mmap-age patch, page cache pages aren't aged
> 
> The age of a page cache page isn't changed if a process took it (?). IMHO that
> means that this age is the starting age of such a process page, isn't it?

No, it means that page-cache pages are swapped out immediately,
without taking the usage pattern into account (except when it
got used just before kswapd did it's scanning).

My mmap-age patch does something to alleviate this, and I'll
make a patch against 2.1.89-pre2 any moment. You can probably
expect it on linux-mm before 0000UT this evening...

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
