Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA04176
	for <linux-mm@kvack.org>; Tue, 18 Nov 1997 07:17:10 -0500
Date: Tue, 18 Nov 1997 10:56:46 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: [PATCH] vhand-2.1.63 
In-Reply-To: <m0xXSuK-000sOuC@linux.biostat.hfh.edu>
Message-ID: <Pine.LNX.3.91.971118104705.359A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Noel Maddy <ncm@biostat.hfh.edu>
Cc: linux-kernel@vger.rutgers.edu, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 17 Nov 1997, Noel Maddy wrote:

> > I noticed that after kernel was running some time, it become quite
> > unresponsive (moving mouse in X and so.). And vhand kernel thread is
> > definitely burning too much CPU cycles (sometimes it uses up to 10% of
> > CPU!?):
> > 
> >     0     2     1  13:10  ?    0:14 kflushd
> >     0     3     1  13:10  ?    0:03 kswapd
> >     0     4     1  13:10  ?    7:51 vhand  <<--
> >     0    11     1  13:11  ?    0:01 update
> 
> Now, that's interesting.  I have had very noticable improvements in 
> responsiveness when my system is heavily into swap.  Also, I haven't 
> seen vhand take up much CPU time at all.  Of course, I've only had 
> vhand up for a day or so at a time -- I have to work in NT as well :(

There is a situation in which vhand _does_ use up far to much CPU
time. It is when the system continuously loads new things into
memory which it only uses once/twice, and the rest of memory gets
used continuously. I think I'm going to boost up the kswapd_max_fail
because obviously there _is_ 1/32 of memory ready to swap out, it's
just that kswapd isn't at that point in memory :-(
> 
> I've got a 32MB 200MMX, and am running glibc 2.0.5c from Debian 
> unstable.  I also run the Enlightenment window manager, which is very 
> graphics-intensive, and can use a lot of memory.  The problem comes 
> when I start Netscape.  Not only is it memory-voracious, but it's libc5 
> -- the only libc5 program I run any more.
> 
> Without the vhand patch, the system is often nearly  unusable when I 
> load Netscape.  I can't get more than about 20MB into swap without the 
> system thrashing and response deteriorating -- Enlightenment and 
> Netscape will put me there right away.
> 
> With the vhand patch, the response is much crisper, and I am even able 
> to run gimp and Netscape simultaneously (over 40MB in to swap) without 
> serious problems.

This is my test as well, I run X, Netscape, a HTTP proxy (wwwoffle),
Afterstep&Wharf and 6 xanims... No problem :-)
> 
> On the other hand, it does seem that programs take longer to start up 
> with the vhand patch -- perhaps this could be affecting the kernel 
> compilation as well.

This probably is because the system is more careful about which
page to kick out of memory... This way it takes (a bit) longer
to free all the memory. And remember, vhand gets woken up and runs
(maybe half a jiffie). If it doesn't run a full jiffie, the cost
is billed to the program that is running the next jiffie :-(
> 
> Anyway, 2.1.63-vhand is the kernel for me right now.  Thanks :)
No thanks. Your story has been helpful to me.
In fact, I need/'d like to have more success/failure stories.
Up to now I'v only had success stories (and 2 of decreasing performance
with kernel compiling). Without real failures, I might send it to
Linus later this week...

Rik.

----------
Send Linux memory-management wishes to me: I'm currently looking
for something to hack...
