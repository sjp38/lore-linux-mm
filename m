Date: Tue, 22 Oct 2002 20:43:13 +0200
From: bert hubert <ahu@ds9a.nl>
Subject: vm scenario tool / mincore(2) functionality for regular pages?
Message-ID: <20021022184313.GA12081@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I'm building a tool to subject the VM to different scenarios and I'd like to
be able to determine if a page is swapped out or not. For a file I can
easily determine if a page is in memory (in the page cache) or not using the
mincore(2) system call.

I want to expand my tool so it can investigate which of its pages are
swapped out under cache pressure or real memory pressure.

However, to do this, I need a way to determine if a page is there or if it
is swapped out. My two questions are:

	1) is there an existing way to do this
	   (the kernel obviously knows)

	2) would it be correct to expand mincore to also work on
           non-filebacked memory so it works for 'swap-backed' memory too?

Thanks.

Some current output of the scenario tool:

vmloader> alloc 25
Arena now 25 megabytes, 6250 pages

vmloader> sweep
Sweeping from mbyte 0 to 25, 6250 pages. Done

vmloader> rusage
minor: 6250, major: 2, swaps: 0

vmloader> sweep 0 12
Sweeping from mbyte 0 to 12, 1440 pages. Done

vmloader> rusage
minor: 0, major: 0, swaps: 0

vmloader> touch
Touching from mbyte 0 to 25, 6250 pages. Done

vmloader> rusage
minor: 6249, major: 0, swaps: 0

vmloader> rsweep
Random sweeping from mbyte 0 to 25, 6250 pages. Done

vmloader> rusage
minor: 0, major: 0, swaps: 0


-- 
http://www.PowerDNS.com          Versatile DNS Software & Services
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
