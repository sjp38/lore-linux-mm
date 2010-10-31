Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BEEF78D005B
	for <linux-mm@kvack.org>; Sat, 30 Oct 2010 22:32:06 -0400 (EDT)
Date: Sat, 30 Oct 2010 22:31:45 -0400
From: Ted Ts'o <tytso@mit.edu>
Subject: Re: 2.6.36 io bring the system to its knees
Message-ID: <20101031023145.GB1869@thunk.org>
References: <AANLkTikvSGNE7uGn5p0tfJNg4Hz5WRmLRC8cXu7+GhMk@mail.gmail.com>
 <20101028090002.GA12446@elte.hu>
 <AANLkTinoGGLTN2JRwjJtF6Ra5auZVg+VSa=TyrtAkDor@mail.gmail.com>
 <20101028133036.GA30565@elte.hu>
 <20101028170132.GY27796@think>
 <AANLkTikgO=n88ZAQ6EYAg1+aC1d0+o923FYyhkOouaH5@mail.gmail.com>
 <20101029145212.GA21205@thunk.org>
 <AANLkTim-A7DLOOw4myQU3Lfip+ZEE32F2Ap_PJXuxG6G@mail.gmail.com>
 <20101030091440.GA15276@elte.hu>
 <AANLkTim-hgA3-9T_N5k53Sga5LMazMQPmmQZzQsoQvRY@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTim-hgA3-9T_N5k53Sga5LMazMQPmmQZzQsoQvRY@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Aidar Kultayev <the.aidar@gmail.com>
Cc: Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Arjan van de Ven <arjan@infradead.org>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

On Sat, Oct 30, 2010 at 07:02:35PM +0600, Aidar Kultayev wrote:
> the system is/was doing :
> .dd if=/dev/zero of=test.10g bs=1M count=10000;rm test.10g
> .netbeans
> .compiling gcc-4.5.1
> .running VBox, which wasn't doing any IO. The guest os was idle in other words
> .vlc
> .chromium
> .firefox
> and bunch of other small stuff.
> 
> Even without having running DD, the mouse cursor would occasionally
> lag. The alt+tab effect in KWin would take 5+seconds to workout.
> When I run DD on top of the workload it consistently made system much
> more laggy. The cursor would freeze much more frequent. It is like if
> you drag your mouse physically, but the cursor on the screen would
> jump discretely, in other words there is no continuity.
> Music would stop.

If you start shutting down tasks, Vbox, netbeans, chromium, etc., at
what point does the cursor start tracking the system easily?  Is the
system swapping?  Do you know how to use tools like dstat or iostat to
see if the system is actively writing to the swap partition?  (And are
you using a swap partition or a swap file?)

The fact that cursor isn't tracking well even when the dd is running,
and presumably the only source of I/O is the gcc and vlc, makes me
suspect that you may be swapping pretty heavily.  Have you tried
investigating that possibility, and made sure it has been ruled out?

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
