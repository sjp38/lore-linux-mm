Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA18648
	for <linux-mm@kvack.org>; Wed, 25 Feb 1998 18:52:09 -0500
Date: Thu, 26 Feb 1998 00:26:19 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: your mail
In-Reply-To: <Pine.LNX.3.95.980225144057.8068C-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.91.980226002406.9760A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Feb 1998, Linus Torvalds wrote:

> > We could simply prohibit the VM subsystem from swapping
> > out pages which have been allocated less than one second
> > ago, this way the movement of pages becomes 'slower', and
> > thrashing might get somewhat less.
> 
> The reason I dislike rate-based things is that it is _so_ hard to give any
> kind of guarantees at all on the sanity of the thing. You can tweak the
> rates, but they don't have any logic to them, and most importantly they
> are very hard to make self-tweaking. 

Yup, I don't like 'em either, but I proposed it anyways
in case anyone of you might like it :-)
Personally, I like balancing code too, if possible with
some balancing on the balancing code as well...

OK, we go with balancing code.

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
