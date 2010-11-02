Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A75746B0095
	for <linux-mm@kvack.org>; Tue,  2 Nov 2010 09:14:15 -0400 (EDT)
Date: Tue, 2 Nov 2010 09:12:39 -0400
From: Chris Mason <chris.mason@Oracle.COM>
Subject: Re: 2.6.36 io bring the system to its knees
Message-ID: <20101102131239.GA8680@think>
References: <20101028170132.GY27796@think>
 <E1PDFKe-0005sq-2D@approx.mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1PDFKe-0005sq-2D@approx.mit.edu>
Sender: owner-linux-mm@kvack.org
To: Sanjoy Mahajan <sanjoy@olin.edu>
Cc: Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Aidar Kultayev <the.aidar@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Peter.Zijl@MIT.EDU
List-ID: <linux-mm.kvack.org>

On Tue, Nov 02, 2010 at 07:47:15AM -0400, Sanjoy Mahajan wrote:
> Chris Mason <chris.mason@oracle.com> wrote:
> 
> > > This has the appearance of some really bad IO or VM latency
> > > problem. Unfixed and present in stable kernel versions going from
> > > years ago all the way to v2.6.36.
> > 
> > Hmmm, the workload you're describing here has two special parts.
> > First it dramatically overloads the disk, and then it has guis doing
> > things waiting for the disk.
> 
> I think I see this same issue every few days when I back up my hard
> drive to a USB hard drive using rsync.  While the backup is running, the
> interactive response is bad.  A reproducible measurement of the badness
> is starting an rxvt with F8 (bound to "rxvt &" in my .twmrc).  Often it
> takes 8 seconds for the window to appear (as it just did about 2 minutes
> ago)!  (Starting a subsequent rxvt is quick.)

So this sounds like the backup is just thrashing your cache.  Latencies
starting an app are less surprising than latencies where a running app
doesn't respond at all.

Does rsync have the option to do an fadvise DONTNEED?

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
