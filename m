Message-ID: <3D783156.68A088D1@zip.com.au>
Date: Thu, 05 Sep 2002 21:38:46 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: slablru for 2.5.32-mm1
References: <Pine.LNX.4.44.0209052032410.30628-100000@loke.as.arizona.edu>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Craig Kulesa <ckulesa@as.arizona.edu>
Cc: linux-mm@kvack.org, Ed Tomlinson <tomlins@cam.org>
List-ID: <linux-mm.kvack.org>

Craig Kulesa wrote:
> 
> Ed Tomlinson wrote:
> >> Andrew Morton wrote:
> >>
> >> The patch does a zillion BUG->BUG_ON conversions in slab.c, which is a
> >> bit unfortunate, because it makes it a bit confusing to review.  Let's
> >> do that in a standalone patch next time ;)
> >
> > Yes.  I would have left the BUG_ONs till later.  Craig thought
> > otherwise.  I do agree two patches would have been better.
> 
> I agree also.  I never imagined that patch would make it up the ladder
> before the BUG_ON's changes got split out into a separate patch.  Sorry!
> So... since I introduced the BUG_ON's, I thought I should clean it up.
> 
> This is mostly for Ed and Andrew, but at:
>         http://loke.as.arizona.edu/~ckulesa/kernel/rmap-vm/2.5.33/
> 
> you can get a copy of Andrew's slablru.patch from the 2.5.33-mm3 series
> where I have altered fs/dcache.c and mm/slab.c (whose patches otherwise
> apply cleanly to vanilla 2.5.33) to remove the BUG_ON changes.  It does
> reduce the size of the patch, and improves its readability considerably.
> Hope that helps.

Thanks.  This patch is in Ed's hands at present - his call.

> ----
> 
> I have a terribly naive question to add though.  From the original message
> in this thread, Andrew reverted this BUG_ON due to side-effects:
> 
>         BUG_ON(smp_call_function(func, arg, 1, 1));
> 
> I must be dense -- why?  All we are doing is passing gcc the hint that
> this is an unlikely path, and surely that's true?  I mean, if it's not,
> don't we have other things to worry about?
> 

Because some crazy embedded system person may want to save some
bytes by using:

#define BUG_ON(x)	do { } while (0)

Which is quite legitimate - it's just debug.   We should attempt to
support that, I suggest.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
