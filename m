Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA09556
	for <linux-mm@kvack.org>; Wed, 22 Apr 1998 13:57:18 -0400
Subject: Re: (reiserfs) Re: Maybe we can do 40 bits in June/July. (fwd)
References: <Pine.LNX.3.91.980422151602.31012F-100000@mirkwood.dummy.home>
From: ebiederm+eric@npwt.net (Eric W. Biederman)
In-Reply-To: Rik van Riel's message of Wed, 22 Apr 1998 15:18:19 +0200 (MET DST)
Date: 22 Apr 1998 12:57:01 -0500
Message-ID: <m1yawxoi36.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: H.H.vanRiel@phys.uu.nl
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>>>>> "RR" == Rik van Riel <H.H.vanRiel@phys.uu.nl> writes:

RR> Hi guys,
RR> I just got this message from Hans Reiser (the main
RR> ReiserFS coordinator), who says that ReiserFS will
RR> be 40-bits (1TB filesize) ready by june/juli this
RR> year.
RR> Now we (the MM guys) need to get together and make
RR> the MM layer 40-bit transparent too (or 41-bit).

RR> Any takers?

I will make at least a preliminary patch.  

I have already started.

My design:
As I understand it the buffer cache is fine, so it is just a matter
getting the page cache and the vma and the glue working.

My thought is to make the page cache use generic keys. 
This should help support things like the swapper inode a little
better.  Still need a bit somewhere so we can coallese VMA's that have
an inode but don't need continous keys.  That's for later.

For the common case of inodes have the those keys:
page->key == page->offset >> PAGE_SHIFT.

And of course get rid of page->offset.  The field name changes will to
catch any old code that is out there.

Eric
