Received: from naughty.monkey.org (overtill@naughty.monkey.org [152.160.231.194])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA07285
	for <linux-mm@kvack.org>; Thu, 11 Feb 1999 17:02:40 -0500
Date: Thu, 11 Feb 1999 17:02:20 -0500 (EST)
From: Chuck Lever <cel@monkey.org>
Subject: page coloring
Message-ID: <Pine.BSF.3.96.990211163732.6381B-100000@naughty.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

i've been looking more at page coloring.  there's an excellent thesis on
the topic:

William L. Lynch, "The Interaction of Virtual Memory and Cache Memory,"
Technical Report CSL-TR-93-587, Computer Systems Laboratory, Department of
Electrical Enginerring and Computer Science, Standford University, October
1993.

you can find postscript at: 
	ftp://umunhum.stanford.edu/tr/lynch.thesis.ps.Z

Lynch describes virtual memory and cache memory interactions, and provides
a taxonomy of coloring algorithms.  he then demonstrates, using
simulations and statistics, which algorithms are most effective at
reducing mean miss rate and inter-run variation.  finally, he measures
changes in virtual memory behavior (e.g. page fault rate and effective
memory utilization).

Lynch shows that there are only two algorithms worth considering, and
neither of them is very complex. i think the hard part will be efficiently
managing multiple buckets of free frames of the same color, given the
lengths to which the Linux page allocator goes to achieve performance.

	- Chuck Lever
--
corporate:	<chuckl@netscape.com>
personal:	<chucklever@netscape.net> or <cel@monkey.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
