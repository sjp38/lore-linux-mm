From: "William J. Earl" <wje@cthulhu.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14416.15954.354222.915088@liveoak.engr.sgi.com>
Date: Thu, 9 Dec 1999 15:42:10 -0800 (PST)
Subject: Re: Getting big areas of memory, in 2.3.x?
In-Reply-To: <E11wC1Q-0002fc-00@the-village.bc.nu>
References: <14416.10643.915336.498552@liveoak.engr.sgi.com>
	<E11wC1Q-0002fc-00@the-village.bc.nu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: mingo@chiara.csoma.elte.hu, jgarzik@mandrakesoft.com, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Alan Cox writes:
 > >      That is not the case for loadable (modular) drivers.  Loading st
 > > as a module, for example, after boot time sometimes works and sometimes does
 > > not, especially if you set the maximum buffer size larger (to, say, 128K,
 > > as is needed on some drives for good space efficiency).
 > 
 > Dont mix up crap code with crap hardware. Scsi generic had similar problems
 > and has been fixed. There are very very few non scatter-gather scsi controllers

      I only mentioned st as example of the inability to get a large page
long after system startup.  Large pages are good for a variety of purposes.
For example, large pages for programs with large code or data footprints
can dramatically reduce TLB misses.  If the I/O system learns to do direct
I/O, the overhead of setting up large I/O operations, whether for disk I/O
or for OpenGL operations such as writing a large image to the screen
(via DMA), is much reduced when the I/O is done from large pages.
The CPU overhead of setting up I/O operations is pretty minimal when you
are doing file I/O to and from a single IDE disk, but far from minimal
for higher-bandwidth targets, such as a graphics controller or a 
HDTV camera.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
