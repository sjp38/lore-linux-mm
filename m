Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C42676B0085
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 09:27:45 -0500 (EST)
Date: Wed, 10 Nov 2010 15:27:21 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.36 io bring the system to its knees
Message-ID: <20101110142721.GA14496@elte.hu>
References: <20101105014334.GF13830@dastard>
 <E1PELiI-0001Pj-8g@approx.mit.edu>
 <AANLkTimON_GL6vRF9=_U6oRFQ30EYssx3wv5xdNsU9JM@mail.gmail.com>
 <4CD696B4.6070002@kernel.dk>
 <AANLkTikNPEcwWjEQuC-_=9yH5DCCiwUAY265ggeygcSQ@mail.gmail.com>
 <20101110013255.GR2715@dastard>
 <20101110142037.GA1447@ucw.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101110142037.GA1447@ucw.cz>
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@ucw.cz>
Cc: Dave Chinner <david@fromorbit.com>, Linus Torvalds <torvalds@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, dave b <db.pub.mail@gmail.com>, Sanjoy Mahajan <sanjoy@olin.edu>, Jesper Juhl <jj@chaosbits.net>, Chris Mason <chris.mason@oracle.com>, Pekka Enberg <penberg@kernel.org>, Aidar Kultayev <the.aidar@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Arjan van de Ven <arjan@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ted Ts'o <tytso@mit.edu>, Corrado Zoccolo <czoccolo@gmail.com>, Shaohua Li <shaohua.li@intel.com>, Steven Barrett <damentz@gmail.com>
List-ID: <linux-mm.kvack.org>


* Pavel Machek <pavel@ucw.cz> wrote:

> Hi!
> 
> > > > As already mentioned, ext3 is just not a good choice for this sort of
> > > > thing. Did you have atimes enabled?
> > > 
> > > At least for ext3, more important than atimes is the "data=writeback"
> > > setting. Especially since our atime default is sane these days (ie if
> > > you don't specify anything, we end up using 'relatime').
> > > 
> > > If you compile your own kernel, answer "N" to the question
> > > 
> > >   Default to 'data=ordered' in ext3?
> > > 
> > > at config time (CONFIG_EXT3_DEFAULTS_TO_ORDERED), or you can make sure
> > > "data=writeback" is in the fstab (but I don't think everything honors
> > > it for the root filesystem).
> > 
> > Don't forget to mention data=writeback is not the default because if your system 
> > crashes or you lose power running in this mode it will *CORRUPT YOUR FILESYSTEM* 
> > and you *WILL LOSE DATA*. Not to mention
> 
> You will lose your data, but the filesystem should still be consistent, right? 
> Metadata are still journaled.

That is data that was freshly touched around the time the system went down, right?

I.e. data that was probably half-modified by user-space to begin with.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
