Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id VAA19532
	for <linux-mm@kvack.org>; Thu, 20 Nov 1997 21:00:08 -0500
Date: Fri, 21 Nov 1997 02:37:23 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: [PATCH *] vhand-2.1.65b released
In-Reply-To: <19971120152522.39483@helix.caltech.edu>
Message-ID: <Pine.LNX.3.91.971121023024.692A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Joe Fouche <jf@ugcs.caltech.edu>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 20 Nov 1997, Joe Fouche wrote:

> You wrote
> > since so many people have found something wrong with vhand-2.1.6[45]
> > (particularly the CPU usage), I have implemented their ideas and
> > I've made the 'anti-fragmentation' unit even more agressive, since
> > some people still reported crashes because of memory fragmentation...
> 
> This one (65b) is really good. I also found that I could decrease the numbers
> in /proc/sys/vm/freepages (I had them set kind of high) to improve all-around 
> interactive performance.

All-round performance is improved, but mostly on small-memory
machines... We still need to do some tuning and optimization
for special cases of memory usage (linear, directory scanning,
etc..).
> 
> root         3  0.0  0.0     0     0  ?  SW< 11:34   0:00 (kswapd)
> root         4  1.0  0.0     0     0  ?  SW  11:34   2:16 (vhand)    
See, the CPU usage is way to high. It might be OK for a 32Meg
system, but imagine someone trying this on a 512Meg system :)
Actually, someone with a 512Meg system agreed to try my patch
this weekend.  If things go well the patch might be ready for
integration in the mainstream kernel...

> A good way to test vhand, then, might be to make freepages really high and watch
> as things get swapped out. :)
More importantly, does the system remain stable with an ultra-low
value of freepages?
> 
> Wonder if the kernel could tune freepages automatically, based on some measure
> of the performance of swap devices? Maybe the same thing would apply to some of
> the numbers in struct swap_control_v5? 

But of course it could. Setting the value of min_free_pages to the
average nr of pagefaults we had during the last time (weighed after
time...) could result in a smaller number of freepages when we don't
need them, and increase the number of freepages when we need the
memory most. Hmm, I gotta try this one.
> 
> Anyway, send it to Linus, it works great! :)

It works great for US, small-memory users. But there are also
those people around who have large (> 64M) memory systems.  I
won't send it to Linus unless I know it works _flawlessly_ on
large-memory systems as well.

Rik.

----------
Send Linux memory-management wishes to me: I'm currently looking
for something to hack...
