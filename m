Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 50BC06B00AF
	for <linux-mm@kvack.org>; Fri,  5 Nov 2010 08:48:24 -0400 (EDT)
Message-ID: <E1PELiI-0001Pj-8g@approx.mit.edu>
Subject: Re: 2.6.36 io bring the system to its knees
In-Reply-To: Your message of "Fri, 05 Nov 2010 12:43:34 +1100."
             <20101105014334.GF13830@dastard>
Date: Fri, 5 Nov 2010 08:48:13 -0400
From: Sanjoy Mahajan <sanjoy@olin.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Jesper Juhl <jj@chaosbits.net>, Chris Mason <chris.mason@oracle.com>, Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Aidar Kultayev <the.aidar@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Arjan van de Ven <arjan@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ted Ts'o <tytso@mit.edu>, Corrado Zoccolo <czoccolo@gmail.com>, Shaohua Li <shaohua.li@intel.com>, Steven Barrett <damentz@gmail.com>
List-ID: <linux-mm.kvack.org>

Dave Chinner <david@fromorbit.com> wrote:

> I think anyone reporting a interactivity problem also needs to
> indicate what their filesystem is, what mount paramters they are
> using, what their storage config is, whether barriers are active or
> not, what elevator they are using, whether one or more of the
> applications are issuing fsync() or sync() calls, and so on.

Good idea.  

The filesystems are all ext3 with default mount parameters.  The dmesgs
say that the filesystems are mounted in ordered data mode and that
barriers are not enabled.

mount says:

/dev/sda2 on / type ext3 (rw,errors=remount-ro,commit=0)
/dev/sda1 on /boot type ext3 (rw,commit=0)
/dev/sda3 on /home type ext3 (rw,commit=0)

> storage config

Do you mean the partition sizes?  Here's that:

$ df -h
Filesystem            Size  Used Avail Use% Mounted on
/dev/sda2              72G   52G   17G  77% /
tmpfs                 755M  4.0K  755M   1% /lib/init/rw
udev                  750M  212K  750M   1% /dev
tmpfs                 755M     0  755M   0% /dev/shm
/dev/sda1             274M  117M  143M  45% /boot
/dev/sda3              74G   37G   33G  53% /home

> elevator

CFQ

> sync-related calls

I don't have a test from the time I ran rsync (but I'll check that
tonight), but I traced the currently running emacs and iceweasel
(a.k.a. firefox) with "strace -p PID 2>&1 | grep sync".  That didn't
turn up any sync-related calls.

(I checked the firefox because I seem to remember that it used to do
fsync absurdly often, but I also seem to remember that the outcry made
them stop.)

-Sanjoy

`Until lions have their historians, tales of the hunt shall always
 glorify the hunters.'  --African Proverb

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
