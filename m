Date: Mon, 2 Oct 2006 21:07:22 -0500
From: Mark Nipper <nipsy@bitgnome.net>
Subject: Re: kernel: pageout: orphaned page with reiserfs v3 in data=journal  mode under 2.6.18
Message-ID: <20061003020719.GA28692@king.bitgnome.net>
References: <20061002170353.GA26816@king.bitgnome.net> <20061002180603.b19bfbd0.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061002180603.b19bfbd0.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 02 Oct 2006, Andrew Morton wrote:
> On Mon, 2 Oct 2006 12:03:54 -0500
> Mark Nipper <nipsy@bitgnome.net> wrote:
> 
> >         I saw this in my logs earlier today:
> > ---
> > kernel: pageout: orphaned page
> > 
> >         It's the first time I've seen it on this box, but I also
> > just switched to data=journal mode for all of my reiserfs mounts
> > yesterday after a hard drive died in a software RAID-1 volume
> > <snipped>
> I think that's a piece of temporary debugging code which I put in there in
> a fit of curiosity and which I then promptly forgot about.
> 
> It's been in there since March 2005 and you are the first person who has
> reported seeing the message...

        Okay.  Thanks for replying Andrew.  I just wanted to make
sure my kernel wasn't going to eat itself at some point.  :)

-- 
Mark Nipper                                                e-contacts:
4320 Milam Street                                   nipsy@bitgnome.net
Bryan, Texas 77801-3920                     http://nipsy.bitgnome.net/
(979)575-3193                      AIM/Yahoo: texasnipsy ICQ: 66971617

-----BEGIN GEEK CODE BLOCK-----
Version: 3.1
GG/IT d- s++:+ a- C++$ UBL++++$ P--->+++ L+++$ !E---
W++(--) N+ o K++ w(---) O++ M V(--) PS+++(+) PE(--)
Y+ PGP t+ 5 X R tv b+++@ DI+(++) D+ G e h r++ y+(**)
------END GEEK CODE BLOCK------

---begin random quote of the moment---
You need a license to drive a car, but any idiot can have a
child.
----end random quote of the moment----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
