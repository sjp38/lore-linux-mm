Received: from kanga.kvack.org (root@kanga.kvack.org [205.189.68.98])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA01230
	for <linux-mm@kvack.org>; Sat, 30 Jan 1999 12:01:25 -0500
Date: Sat, 30 Jan 1999 12:00:53 -0500 (EST)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: Large memory system
In-Reply-To: <19990130083631.B9427@msc.cornell.edu>
Message-ID: <Pine.LNX.3.95.990130114256.27443A-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Daniel Blakeley <daniel@msc.cornell.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 30 Jan 1999, Daniel Blakeley wrote:

> Hi,
> 
> I've jumped the gun a little bit and recommended a Professor buy 4GB
> of RAM on a Xeon machine to run Linux on and he did.  After he got it
> I read the large memory howto which states that the max memory size
> for Linux 2.2.x is 2GB physical/2GB virtual.  The memory size seems to
> limited by the 32bit nature of the x86 architecture.  The Xeon seems
> to have a 36bit memory addressing mode.  Can Linux be easily expanded
> to use the 36bit addressing?

Easily isn't a good way of putting it, unless you're talking about doing
something like mmap on /dev/mem, in which case you could make the
user/kernel virtual spilt weigh heavy on the user side and do memory
allocation yourself.  If you're talking about doing it transparently,
you're best bet is to do something like davem's suggested high mem
approach, and only use non-kernel mapped memory for user pages... if you
want to be able to support the page cache in high memory, things get
messy.

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
