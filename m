Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA23388
	for <linux-mm@kvack.org>; Fri, 28 Aug 1998 18:16:45 -0400
Subject: Re: [PATCH] 498+ days uptime
References: <199808262153.OAA13651@cesium.transmeta.com> 	<87ww7v73zg.fsf@atlas.CARNet.hr> <199808280935.KAA06221@dax.dcs.ed.ac.uk>
Reply-To: Zlatko.Calusic@CARNet.hr
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 29 Aug 1998 00:16:34 +0200
In-Reply-To: "Stephen C. Tweedie"'s message of "Fri, 28 Aug 1998 10:35:36 +0100"
Message-ID: <87ogt4hhvh.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "H. Peter Anvin" <hpa@transmeta.com>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, Linux-MM List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" <sct@redhat.com> writes:

> Hi,
> 
> On 27 Aug 1998 00:49:55 +0200, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
> said:
> 
> > I thought it was done this way (update running in userspace) so to
> > have control how often buffers get flushed. But, I believe bdflush
> > program had this functionality, and it is long gone (as you correctly
> > noticed).
> 
> update(8) _is_ the old bdflush program. :)

I know. But in that old days, I believe, we had two daemons, update
AND bdflush. They were started from the same binary, but their
functionality was different.

Too bad 1.2.13 can't be compiled in todays setups. :)

> 
> There are two entirely separate jobs being done.  One is to flush all
> buffers which are beyond their dirty timelimit: that job is done by the
> bdflush syscall called by update/bdflush every 5 seconds.  The second
> job is to trickle back some dirty buffers to disk if we are getting
> short of clean buffer space in memory. 
> 
> These are completely different jobs.  They select which buffers and how
> many buffers to write based on different criteria, and they are woken up
> by different events.  That's why we have two daemons.  The fact that one
> spends its wait time in user mode and one spends its time in kernel mode
> is irrelevant; even if they were both kernel threads we'd still have two
> separate jobs needing done.

Right, I agree entirely.

Maybe I should reformulate my question. :)

Why is the former in the userspace?

I believe it is not that hard to code bdflush in the kernel, where we
lose nothing, but save few pages of memory. One less process to run,
as I already pointed out.

You probably did have an opportunity to visit Paul Gortmaker's page,
helpful for those with low memory machines. There you can find "few
lines of assembly" program that replaces update. I ran that program
for few years to save few kilobytes of memory on my old 386 / 5MB RAM.

> 
> > I'm crossposting this mail to linux-mm where some clever MM people can
> > be found. Hopefully we can get an explanation why do we still need
> > update.
> 
> Because kflushd does not do the job which update needs to do.  It does a
> different job.
> 

Yep, but allow me one more question, please.

If I happen to get some free time (very unlikely) to code bdflush
completely in the kernel, so we can get rid of update, now running as
daemon, would you consider it for inclusion in the official kernel
(sending patches to Linus, etc..)? 
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
		  It's bad luck to be superstitious.
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
