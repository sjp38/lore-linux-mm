Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz [195.113.31.123])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA09817
	for <linux-mm@kvack.org>; Thu, 18 Dec 1997 09:18:20 -0500
Message-ID: <19971218143455.37139@Elf.mj.gts.cz>
Date: Thu, 18 Dec 1997 14:34:55 +0100
From: Pavel Machek <pavel@Elf.mj.gts.cz>
Subject: Re: Slow memory support
References: <19971217221622.50179@Elf.mj.gts.cz> <Pine.LNX.3.91.971218000718.887B-100000@mirkwood.dummy.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.3.91.971218000718.887B-100000@mirkwood.dummy.home>; from Rik van Riel on Thu, Dec 18, 1997 at 12:09:13AM +0100
Sender: owner-linux-mm@kvack.org
To: H.H.vanRiel@fys.ruu.nl
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Wed, 17 Dec 1997, Pavel Machek wrote:
> 
> > This is what I do. (I only put buffers there, for now). But, what
> > about you have 64Meg of normal and 64Meg of slow memory? I doubt
> > you'll find 64Meg worth of buffers and page tables.
> 
> Hmm, what about putting everything in slow memory, except
> for executable code...

And what to do with executable data? I think that data need to be in
fast mem, too.

> Or (with Ben's patch) we could move 'overly active' pages
> to fast memory and other pages to slow memory, with a max
> amount of pages we could move every second.

This would be nice. What is Ben's patch?
								Pavel

-- 
I'm really pavel@atrey.karlin.mff.cuni.cz. 	   Pavel
Look at http://atrey.karlin.mff.cuni.cz/~pavel/ ;-).
