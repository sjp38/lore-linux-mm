Subject: Re: Getting big areas of memory, in 2.3.x?
Date: Thu, 9 Dec 1999 23:50:04 +0000 (GMT)
In-Reply-To: <14416.15954.354222.915088@liveoak.engr.sgi.com> from "William J. Earl" at Dec 9, 99 03:42:10 pm
Content-Type: text
Message-Id: <E11wDK1-0002nT-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "William J. Earl" <wje@cthulhu.engr.sgi.com>
Cc: alan@lxorguk.ukuu.org.uk, mingo@chiara.csoma.elte.hu, jgarzik@mandrakesoft.com, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> For example, large pages for programs with large code or data footprints
> can dramatically reduce TLB misses.  If the I/O system learns to do direct

Yep. One thing Irix always seemed to be rather neat about was page size
dependant on ram size of box.

> I/O, the overhead of setting up large I/O operations, whether for disk I/O
> or for OpenGL operations such as writing a large image to the screen
> (via DMA), is much reduced when the I/O is done from large pages.

PC's have the AGP GART. That provides an MMU for the graphics card in effect.

> for higher-bandwidth targets, such as a graphics controller or a 
> HDTV camera.

I don't know of any capture cards that don't do scatter gather. Most of them
do scatter gather with skipping and byte alignment so you can DMA around
other windows.

This is the main point. There are so so few devices that actually _have_ to
have lots of linear memory it is questionable that it is worth paying the
price to allow modules to allocate that way

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
