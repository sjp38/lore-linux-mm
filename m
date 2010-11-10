Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B22EC6B004A
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 09:20:47 -0500 (EST)
Date: Wed, 10 Nov 2010 15:20:37 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: 2.6.36 io bring the system to its knees
Message-ID: <20101110142037.GA1447@ucw.cz>
References: <20101105014334.GF13830@dastard>
 <E1PELiI-0001Pj-8g@approx.mit.edu>
 <AANLkTimON_GL6vRF9=_U6oRFQ30EYssx3wv5xdNsU9JM@mail.gmail.com>
 <4CD696B4.6070002@kernel.dk>
 <AANLkTikNPEcwWjEQuC-_=9yH5DCCiwUAY265ggeygcSQ@mail.gmail.com>
 <20101110013255.GR2715@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101110013255.GR2715@dastard>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, dave b <db.pub.mail@gmail.com>, Sanjoy Mahajan <sanjoy@olin.edu>, Jesper Juhl <jj@chaosbits.net>, Chris Mason <chris.mason@oracle.com>, Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Aidar Kultayev <the.aidar@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Arjan van de Ven <arjan@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ted Ts'o <tytso@mit.edu>, Corrado Zoccolo <czoccolo@gmail.com>, Shaohua Li <shaohua.li@intel.com>, Steven Barrett <damentz@gmail.com>
List-ID: <linux-mm.kvack.org>

Hi!

> > > As already mentioned, ext3 is just not a good choice for this sort of
> > > thing. Did you have atimes enabled?
> > 
> > At least for ext3, more important than atimes is the "data=writeback"
> > setting. Especially since our atime default is sane these days (ie if
> > you don't specify anything, we end up using 'relatime').
> > 
> > If you compile your own kernel, answer "N" to the question
> > 
> >   Default to 'data=ordered' in ext3?
> > 
> > at config time (CONFIG_EXT3_DEFAULTS_TO_ORDERED), or you can make sure
> > "data=writeback" is in the fstab (but I don't think everything honors
> > it for the root filesystem).
> 
> Don't forget to mention data=writeback is not the default because if
> your system crashes or you lose power running in this mode it will
> *CORRUPT YOUR FILESYSTEM* and you *WILL LOSE DATA*. Not to mention

You will lose your data, but the filesystem should still be
consistent, right? Metadata are still journaled.

> the significant security issues (e.g stale data exposure) that also
> occur even if the filesystem is not corrupted by the crash. IOWs,

I agree on security issues.
									Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
