Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA01320
	for <linux-mm@kvack.org>; Mon, 1 Feb 1999 14:34:25 -0500
Received: from mirkwood.dummy.home (root@anx1p7.phys.uu.nl [131.211.33.96])
	by max.phys.uu.nl (8.9.1/8.9.1/hjm) with ESMTP id RAA29983
	for <linux-mm@kvack.org>; Mon, 1 Feb 1999 17:12:30 +0100 (MET)
Date: Mon, 1 Feb 1999 16:59:22 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: Large memory system
In-Reply-To: <19990130083631.B9427@msc.cornell.edu>
Message-ID: <Pine.LNX.4.03.9902011656370.6909-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Daniel Blakeley <daniel@msc.cornell.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 30 Jan 1999, Daniel Blakeley wrote:

> I've jumped the gun a little bit and recommended a Professor buy
> 4GB of RAM on a Xeon machine to run Linux on and he did.  After he
> got it I read the large memory howto which states that the max
> memory size for Linux 2.2.x is 2GB physical/2GB virtual.  The
> memory size seems to limited by the 32bit nature of the x86
> architecture.  The Xeon seems to have a 36bit memory addressing
> mode.  Can Linux be easily expanded to use the 36bit addressing?

Just today there was a patch on linux-kernel with a
patch that allows you to use the top 2 GB as a RAM
disk or something like that.

You can use that for swap and to mmap() stuff on.
I think this could be quite useful for large simulations
and stuff like that.

36-bit addressing is a bit difficult at the moment, but
undoubtedly someone will code up something like that for
Linux 2.3 (maybe the prof could let some (under)graduate
student do this as a major project?).

succes,

Rik -- If a Microsoft product fails, who do you sue?
+-------------------------------------------------------------------+
| Linux Memory Management site:  http://humbolt.geo.uu.nl/Linux-MM/ |
| Nederlandse Linux documentatie:          http://www.nl.linux.org/ |
+-------------------------------------------------------------------+

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
