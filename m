Received: from kanga.kvack.org (root@kanga.kvack.org [205.189.68.98])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA26327
	for <Linux-MM@kvack.org>; Fri, 29 Jan 1999 20:53:29 -0500
Date: Fri, 29 Jan 1999 20:52:51 -0500 (EST)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: Fwd: Inoffensive bug in mm/page_alloc.c
In-Reply-To: <990127235552.n0002181.ph@mail.clara.net>
Message-ID: <Pine.LNX.3.95.990129204839.24246C-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Paul Hamshere <ph@clara.net>
Cc: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Paul,

> Is this of any interest here?

Yep!

> Paul
> ------------------------------
> Hi
> I was trawling through the mm sources to try and understand how linux tracks the
> use of pages of memory, how kmalloc and vmalloc work, and I think there is a bug
> in the kernel (2.0) - it doesn't affect anything, only waste a tiny amount of
> memory....does anyone else think it looks wrong?
> The problem is in free_area_init where it allocates the bitmaps - I think they
> are twice the size they need to be.

If you search the mailing list archives from either a year, maybe two ago,
someone brought forth the same concern, but Linus rejected the patch on
the basis that it wasn't trivially proven correct for *all* sizes of
memory.  The amount of memory involved is insignificant, and I'd speculate
that we'll see a page allocator in 2.3 at which point that loss can
disappear.

		-ben (cleaning out the inbox)

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
