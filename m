Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA09077
	for <linux-mm@kvack.org>; Wed, 22 Apr 1998 12:02:01 -0400
Received: from mirkwood.dummy.home (root@anx1p3.fys.ruu.nl [131.211.33.92])
	by max.fys.ruu.nl (8.8.7/8.8.7/hjm) with ESMTP id SAA23801
	for <linux-mm@kvack.org>; Wed, 22 Apr 1998 18:01:27 +0200 (MET DST)
Date: Wed, 22 Apr 1998 15:18:19 +0200 (MET DST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: H.H.vanRiel@phys.uu.nl
Subject: (reiserfs) Re: Maybe we can do 40 bits in June/July. (fwd)
Message-ID: <Pine.LNX.3.91.980422151602.31012F-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi guys,

I just got this message from Hans Reiser (the main
ReiserFS coordinator), who says that ReiserFS will
be 40-bits (1TB filesize) ready by june/juli this
year.
Now we (the MM guys) need to get together and make
the MM layer 40-bit transparent too (or 41-bit).

Any takers?

Rik.

---------- Forwarded message ----------
Date: Wed, 22 Apr 1998 00:53:03 -0700
From: Hans Reiser <reiser@ricochet.net>
To: H.H.vanRiel@phys.uu.nl
Cc: reiserfs <reiserfs@devlinux.com>
Subject: (reiserfs) Re: Maybe we can do 40 bits in June/July.

Hi Rik,

Ok, I propose the following.  After we stabilize reiserfs but before we
ship it to users we will send you an email saying we are ready to move
to 40 bits.  Then, working in parallel, we will convert both mm and
reiserfs to 40 bits.  You (or somebody you name) will coordinate the mm
portion, and I (or Vladimir) will coordinate the reiserfs portion. 

I anticipate that we will be able to convert ~June, not later than
July.  I anticipate that it will be easy for reiserfs to convert, and
take not long to debug any reiserfs problems that occur.  Since changing
mm will inconvenience other things besides reiserfs, I imagine that you
will want it to be deferred until reiserfs is stable enough for users to
benefit from using 40 bit reiserfs.  Maybe we can implement 40 bits as a
#define in the reiserfs code.

Incidentally, I prefer 40 bits for reiserfs for yet another reason: 64
bits would make our keys overly large.

I am sure that there are a lot of details which we can work out in
June.   

Does this plan sound good to you?

Hans

Rik van Riel wrote:
> 
> On Tue, 21 Apr 1998, Hans Reiser wrote:
> 
> > My current thinking is that we should only worry about 2GB files when
> > Linus and the MM guys indicate they want to deal with making offsets
> > 40bits.  I think it is more work for them than for us, so we should let
> > them tell us when they want it.  I will have us do it whenever they
> > decide they want it.
> 
> I know Linus doesn't mind 40bit offsets. Mj and davem are
> likely to work on it when some FS supports it (they both
> work with large server systems).
> 
> Rik.
> +-------------------------------------------+--------------------------+
> | Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
> |        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
> |     http://www.phys.uu.nl/~riel/          | <H.H.vanRiel@phys.uu.nl> |
> +-------------------------------------------+--------------------------+
