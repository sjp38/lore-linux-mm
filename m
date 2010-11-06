Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 830706B0095
	for <linux-mm@kvack.org>; Sat,  6 Nov 2010 15:11:17 -0400 (EDT)
Date: Sat, 6 Nov 2010 12:10:42 -0700
From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: 2.6.36 io bring the system to its knees
Message-ID: <20101106121042.10b3d96b@infradead.org>
In-Reply-To: <E1PELiI-0001Pj-8g@approx.mit.edu>
References: <20101105014334.GF13830@dastard>
	<E1PELiI-0001Pj-8g@approx.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Sanjoy Mahajan <sanjoy@olin.edu>
Cc: Dave Chinner <david@fromorbit.com>, Jesper Juhl <jj@chaosbits.net>, Chris Mason <chris.mason@oracle.com>, Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Aidar Kultayev <the.aidar@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Thomas Gleixner <tglx@linutronix.de>, Ted Ts'o <tytso@mit.edu>, Corrado Zoccolo <czoccolo@gmail.com>, Shaohua Li <shaohua.li@intel.com>, Steven Barrett <damentz@gmail.com>
List-ID: <linux-mm.kvack.org>

On Fri, 5 Nov 2010 08:48:13 -0400
Sanjoy Mahajan <sanjoy@olin.edu> wrote:

> Dave Chinner <david@fromorbit.com> wrote:
> 
> > I think anyone reporting a interactivity problem also needs to
> > indicate what their filesystem is, what mount paramters they are
> > using, what their storage config is, whether barriers are active or
> > not, what elevator they are using, whether one or more of the
> > applications are issuing fsync() or sync() calls, and so on.
> 
> Good idea.  
> 
> The filesystems are all ext3 with default mount parameters.  The
> dmesgs say that the filesystems are mounted in ordered data mode and
> that barriers are not enabled.

btw few more things to try (from my standard rc.local script):

echo 4096 > /sys/block/sda/queue/nr_requests

for i in `pidof kjournald` ; do ionice -c1 -p $i ; done

echo 75 >  /proc/sys/vm/dirty_ratio


(replace sda with whatever your disk is of course)

-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
