Message-ID: <3D6B0215.9FDECCAC@zip.com.au>
Date: Mon, 26 Aug 2002 21:37:41 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: MM patches against 2.5.31
References: <3D644C70.6D100EA5@zip.com.au> <E17jO6g-0002XU-00@starship> <20020826200048.3952.qmail@thales.mathematik.uni-ulm.de> <E17jQB8-0002Zi-00@starship> <3D6A9E4D.DBCC5D0A@zip.com.au> <20020826234230.B21820@redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>
Cc: Daniel Phillips <phillips@arcor.de>, Christian Ehrhardt <ehrhardt@mathematik.uni-ulm.de>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Benjamin LaHaise wrote:
> 
> On Mon, Aug 26, 2002 at 02:31:57PM -0700, Andrew Morton wrote:
> > I like the magical-removal-just-before-free, and my gut feel is that
> > it'll provide a cleaner end result.
> 
> For the record, I'd rather see explicite removal everwhere.  We received
> a number of complaints along the lines of "I run my app immediately after
> system startup, and it's fast, but the second time it's slower" due to
> the lazy page reclaim in early 2.4.  Until there's a way to make LRU
> scanning faster than page allocation, it can't be lazy.
> 

I think that's what Rik was referring to.

But here, "explicit removal" refers to running lru_cache_del() prior
to the final put_page, rather than within the context of the final
put_page.  So it's a different thing.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
