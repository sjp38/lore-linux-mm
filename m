Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id XAA17671
	for <linux-mm@kvack.org>; Thu, 21 May 1998 23:22:58 -0400
Date: Fri, 22 May 1998 05:21:32 +0200 (MET DST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: Swapping in 2.1.103?
In-Reply-To: <199805220256.TAA17716@mail.netwiz.net>
Message-ID: <Pine.LNX.3.91.980522051257.32316B-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Jim Wilcoxson <jim@meritnet.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

[CC:d to linux-mm because of the TODO list and because Jim
 is generally suggesting to team up with us :) ]

On Thu, 21 May 1998, Jim Wilcoxson wrote:

> Hi Rik - I've been running Linux a few years now, but have only been on the
> mailing list a few days and am not familiar with Linux internals.  I think
> it's a great OS though, and would love to contribute.  I'd like to spend a
> few days reviewing the current file system/paging algorithms and doing some
> tests on my machine to make sure I understand before spouting off
> suggestions.  Is it reasonable to review to 2.0.33 code, or should I look
> at the 2.1.x stuff?

It depends. If you're mainly looking at the 'high-level'
pageout daemon and the mmap() stuff, 2.0.33 will be fine.
The low-level stuff (swapcache, locking, etc) have changed
considerable, and are much more 'interesting' in 2.1.x...

Also, the 2.1 kernel is more interesting because any changes
you make have a larger probability of being saved for
future generations :)

We have several things in the TODO list currently:
- reverse pte lookup  -- being done by sct and blah
- true swapping -- I have the designs next to me, NYI
- out-of-memory process killing -- you can download the bulk
				of the code from my homepage
- swapin clustering -- I have some random thoughts, but NYI
- a zone allocator, instead of the current buddy allocator
		-- I have the design, but NYI
- some minor kswapd fixes -- we know what to fix, just not
			how, and it's minor anyway...
- prepaging -- I have some ideas on how to do this, no
			solid design and NYI

In short, the Linux VM system is nice & fast, but
far from perfect. I think there are still several
man-years to be invested and we can always welcome
a new person to the scene.

There's also a mailing list:
linux-mm@blah.kvack.org    (majordomo@blah.kvack.org)

Rik.
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|     http://www.phys.uu.nl/~riel/          | <H.H.vanRiel@phys.uu.nl> |
+-------------------------------------------+--------------------------+
