Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: slablru for 2.5.32-mm1
Date: Fri, 6 Sep 2002 07:39:27 -0400
References: <Pine.LNX.4.44.0209052032410.30628-100000@loke.as.arizona.edu> <3D783156.68A088D1@zip.com.au>
In-Reply-To: <3D783156.68A088D1@zip.com.au>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200209060739.27058.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>, Craig Kulesa <ckulesa@as.arizona.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On September 6, 2002 12:38 am, Andrew Morton wrote:
> Craig Kulesa wrote:
> > Ed Tomlinson wrote:
> > >> Andrew Morton wrote:
> > >>
> > >> The patch does a zillion BUG->BUG_ON conversions in slab.c, which is a
> > >> bit unfortunate, because it makes it a bit confusing to review.  Let's
> > >> do that in a standalone patch next time ;)
> > >
> > > Yes.  I would have left the BUG_ONs till later.  Craig thought
> > > otherwise.  I do agree two patches would have been better.
> >
> > I agree also.  I never imagined that patch would make it up the ladder
> > before the BUG_ON's changes got split out into a separate patch.  Sorry!
> > So... since I introduced the BUG_ON's, I thought I should clean it up.
> >
> > This is mostly for Ed and Andrew, but at:
> >         http://loke.as.arizona.edu/~ckulesa/kernel/rmap-vm/2.5.33/
> >
> > you can get a copy of Andrew's slablru.patch from the 2.5.33-mm3 series
> > where I have altered fs/dcache.c and mm/slab.c (whose patches otherwise
> > apply cleanly to vanilla 2.5.33) to remove the BUG_ON changes.  It does
> > reduce the size of the patch, and improves its readability considerably.
> > Hope that helps.
>
> Thanks.  This patch is in Ed's hands at present - his call.

Craig, Andrew wants to see if we can get something similar to slablru without
using the lru.  Think its possible, its about half coded.  He also wants to 
eliminate the 'lazy' release of slab pages.  The bottom line is that slablru
is getting rewritten.  

Do you have the BUGON changes in a patch all by themselves?

Ed
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
