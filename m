Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA17955
	for <linux-mm@kvack.org>; Thu, 12 Mar 1998 12:02:57 -0500
Date: Thu, 12 Mar 1998 17:37:12 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: report [PATCH] buffermem limit
Message-ID: <Pine.LNX.3.91.980312173402.664A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: linux-kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi,

I've done some tests with the patch I've just posted,
and results are encouraging indeed.
I managed to do 18 (!) diffs on /usr/src/linux without
much trouble. During that period, all kinds of memory
maps from other programs were paged out and things
kinda thrashed, but WorkMan was able to update it's
slidebars at least once every 2 seconds and even Netscape
(version 3) was usable, as long as you kept moving the
mouse :-)

Maybe it's time for implementing minimum RSS limits
for processes, but this needs to go hand in hand with
process suspension and other things...

Rik.
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|     http://www.fys.ruu.nl/~riel/          | <H.H.vanRiel@fys.ruu.nl> |
+-------------------------------------------+--------------------------+
