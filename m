Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id GAA25932
	for <linux-mm@kvack.org>; Fri, 13 Mar 1998 06:01:01 -0500
Date: Fri, 13 Mar 1998 10:31:38 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: a name for mmscan
Message-ID: <Pine.LNX.3.91.980313102911.4396A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

As Ben didn't yet have a suitable name for mmscan, I
think we should go with the semi-standard of:
vmpager (or kpager, to follow the linux way)

This way, we can make a vmswapper (or kswapd) when
the swapping daemon is ready... ('cause we'll need
real swapping anyways).

vmpager seems to be somewhat of a standard in the
BSD world... (what's the Digital Unix one called?)

Rik.
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|     http://www.fys.ruu.nl/~riel/          | <H.H.vanRiel@fys.ruu.nl> |
+-------------------------------------------+--------------------------+
