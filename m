Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id GAA15471
	for <linux-mm@kvack.org>; Fri, 19 Dec 1997 06:57:51 -0500
Date: Fri, 19 Dec 1997 12:50:03 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: H.H.vanRiel@fys.ruu.nl
Subject: mmap-age patch, comments wanted
Message-ID: <Pine.LNX.3.91.971219124615.17914A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: linux-kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi,

as most of you read, I released my mmap-age patch a few
weeks ago. Since then I've had a few reports of people
(all success stories), but not enough to submit the patch
to Linus.

Although there's no really new code in it, and everything
is well-tested, I'd like a few more reports from people
before sending it off to Linus.

And as to the code-freeze, this patch makes the system
more stable (thanks to Zlatko's part) and there are no
really new features in it, just an old feature aplied
to another part of the system.

As always, go to LinuxHQ, then to the 2.1 unoff patches,
and then my patches-page...

If I get about 10 more success stories (and no bug reports)
I'll send it off to Linus, for a better performing 2.2...

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
