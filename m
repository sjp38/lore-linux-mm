Received: from bucky.physics.ncsu.edu (bucky.physics.ncsu.edu [152.1.119.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA30523
	for <linux-mm@kvack.org>; Tue, 1 Jun 1999 08:37:19 -0400
Date: Tue, 1 Jun 1999 08:51:14 -0400 (EDT)
From: Emil Briggs <briggs@bucky.physics.ncsu.edu>
Message-Id: <199906011251.IAA09750@bucky.physics.ncsu.edu>
Subject: Re: Application load times
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: ak@muc.de, sct@redhat.com, weejock@ferret.lmh.ox.ac.uk
List-ID: <linux-mm.kvack.org>

> 
>2.2 made program loading already quite a bit faster by introducing readahead
>for mmap.
>                     

Yes it sure does -- the original timings were with a 2.0.36 kernel. I 
upgraded that machine to a 2.2 kernel and did some timings (time
to load netscape on a freshly booted machine).

page-cluster   time
  1            10.62
  2             8.38
  3             7.07
  4             6.4
  5             5.53
  6             5.05
  7             4.78


I used a stopwatch so there is certainly some error in the timings.

Emil

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
