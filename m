Subject: Re: Getting big areas of memory, in 2.3.x?
Date: Fri, 10 Dec 1999 00:37:55 +0000 (GMT)
In-Reply-To: <14416.18872.811910.38578@liveoak.engr.sgi.com> from "William J. Earl" at Dec 9, 99 04:30:48 pm
Content-Type: text
Message-Id: <E11wE4L-0002rc-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "William J. Earl" <wje@cthulhu.engr.sgi.com>
Cc: alan@lxorguk.ukuu.org.uk, mingo@chiara.csoma.elte.hu, jgarzik@mandrakesoft.com, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>     Then too, there is the matter of TLB misses for applications which
> visit a lot of data, especially on processors with reasonably large
> caches.  With 4 KB pages and 64 TLB entries, the TLB cannot map all of
> a cache larger than 256 KB.  If the cache is, say, 2 MB and the
> application cycles through many of the pages in the cache in a loop,
> you can wind up with a TLB miss for almost every load (other than those from
> the stack).  With 1 MB pages, there are almost no TLB misses.

With very large amounts of memory I don't doubt this. X86 is alas crippled
with a choice of 4K, 2Mb or 4Mb pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
