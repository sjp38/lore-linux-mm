Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA20434
	for <linux-mm@kvack.org>; Thu, 26 Feb 1998 14:33:53 -0500
Date: Thu, 26 Feb 1998 20:29:45 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: memory limitation test kit (tm) :-)
In-Reply-To: <199802261910.UAA13206@boole.fs100.suse.de>
Message-ID: <Pine.LNX.3.91.980226202708.5590A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Dr. Werner Fink" <werner@suse.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 26 Feb 1998, Dr. Werner Fink wrote:

> Hmmm ... this will lead to increasing swap I/O. This because the
> tsk which currently swaps in a needed page maybe lose an other
> needed page ... even it not lose it the age of such a page is
> decreased ... just like a handicap.

I tested it and lost :-) Better next time...
This patch only shows that we need to go another way,
as I pointed out in my post to linux-mm somewhat earlier
today.

Now we need to focus on design first, before we start
coding around :-)

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
