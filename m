Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 3F55B6B004A
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 13:28:11 -0500 (EST)
Subject: Re: 2.6.36 io bring the system to its knees
From: Mike Galbraith <efault@gmx.de>
In-Reply-To: <AANLkTinYZ2wPeeunFv4Ljm+D9SDLbgzTVmw_P9KQdK16@mail.gmail.com>
References: <20101105014334.GF13830@dastard>
	 <E1PELiI-0001Pj-8g@approx.mit.edu>
	 <AANLkTimON_GL6vRF9=_U6oRFQ30EYssx3wv5xdNsU9JM@mail.gmail.com>
	 <4CD696B4.6070002@kernel.dk>
	 <AANLkTikNPEcwWjEQuC-_=9yH5DCCiwUAY265ggeygcSQ@mail.gmail.com>
	 <20101110013255.GR2715@dastard>
	 <AANLkTinpLuzd5c+WqXoa_0Z=nv=mDgd-k4QZbBZHsQnD@mail.gmail.com>
	 <AANLkTinYZ2wPeeunFv4Ljm+D9SDLbgzTVmw_P9KQdK16@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 10 Nov 2010 11:27:31 -0700
Message-ID: <1289413651.4382.15.camel@maggy.simson.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, dave b <db.pub.mail@gmail.com>, Sanjoy Mahajan <sanjoy@olin.edu>, Jesper Juhl <jj@chaosbits.net>, Chris Mason <chris.mason@oracle.com>, Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Aidar Kultayev <the.aidar@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Arjan van de Ven <arjan@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ted Ts'o <tytso@mit.edu>, Corrado Zoccolo <czoccolo@gmail.com>, Shaohua Li <shaohua.li@intel.com>, Steven Barrett <damentz@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-11-10 at 18:46 +0200, Alexey Dobriyan wrote:
> On Wed, Nov 10, 2010 at 5:59 PM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> > On Tue, Nov 9, 2010 at 5:32 PM, Dave Chinner <david@fromorbit.com> wrote:
> >>
> >> Don't forget to mention data=writeback is not the default because if
> >> your system crashes or you lose power running in this mode it will
> >> *CORRUPT YOUR FILESYSTEM* and you *WILL LOSE DATA*.
> >
> > You will lose data even with data=ordered. All the data that didn't
> > get logged before the crash is lost anyway.
> 
> Linus, are you using with data=writeback?
> 
> Those of us, who did (without UPS), will never do it again.

I've been using it for a looong time on my desktop box.  Yeah, you can
be bitten easier than ordered, and I have been, but it's never been
anything major.  The risk for me is worth it, as data=ordered sucked
really bad.

If I didn't need to maintain compatibility with 30+ old kernels for
regression testing, I'd upgrade desktop to ext4, and likely be happy.

> Propability of non-trivial FS corruption becomes so much bigger.
> I believe from my experience, average number of crashes before
> one loses FS becomes single digit number.

That's not my experience.  I've yet to have to rebuild my ext3 fs since
upgrading box to shiny new opensuse 11.1 (however long ago and how many
many explosions ago that was;)

> With data=ordered, it's quite hard.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
