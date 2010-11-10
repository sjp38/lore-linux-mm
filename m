Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4BF0A6B004A
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 03:25:33 -0500 (EST)
Received: from dastard (unverified [121.44.100.105])
	by mail.internode.on.net (SurgeMail 3.8f2) with ESMTP id 45888754-1927428
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 18:55:30 +1030 (CDT)
Date: Wed, 10 Nov 2010 19:24:58 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: 2.6.36 io bring the system to its knees
Message-ID: <20101110082458.GU2715@dastard>
References: <20101105014334.GF13830@dastard>
 <E1PELiI-0001Pj-8g@approx.mit.edu>
 <AANLkTimON_GL6vRF9=_U6oRFQ30EYssx3wv5xdNsU9JM@mail.gmail.com>
 <4CD696B4.6070002@kernel.dk>
 <AANLkTikNPEcwWjEQuC-_=9yH5DCCiwUAY265ggeygcSQ@mail.gmail.com>
 <20101110013255.GR2715@dastard>
 <AANLkTikAF=Ka_qB5pPzo9wj_jAp=TG2xSbjaGcoLYfBw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTikAF=Ka_qB5pPzo9wj_jAp=TG2xSbjaGcoLYfBw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Evgeniy Ivanov <lolkaantimat@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, dave b <db.pub.mail@gmail.com>, Sanjoy Mahajan <sanjoy@olin.edu>, Jesper Juhl <jj@chaosbits.net>, Chris Mason <chris.mason@oracle.com>, Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Aidar Kultayev <the.aidar@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Arjan van de Ven <arjan@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ted Ts'o <tytso@mit.edu>, Corrado Zoccolo <czoccolo@gmail.com>, Shaohua Li <shaohua.li@intel.com>, Steven Barrett <damentz@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 10, 2010 at 11:08:17AM +0300, Evgeniy Ivanov wrote:
> On Wed, Nov 10, 2010 at 4:32 AM, Dave Chinner <david@fromorbit.com> wrote:
> > Don't forget to mention data=writeback is not the default because if
> > your system crashes or you lose power running in this mode it will
> > *CORRUPT YOUR FILESYSTEM* and you *WILL LOSE DATA*. Not to mention
> > the significant security issues (e.g stale data exposure) that also
> > occur even if the filesystem is not corrupted by the crash. IOWs,
> > data=writeback is the "fast but I'll eat your data" option for ext3.
> >
> > So I recommend that nobody follows this path because it only leads
> > to worse trouble down the road.  Your best bet it to migrate away
> > from ext3 to a filesystem that doesn't have such inherent ordering
> > problems like ext4 or XFS....
> 
> Is it save to use "data=writeback" with ext4?

I believe the same issues exist with data=writeback in ext4, but you
probably should have an ext4 developer answer that question for
certain.

> At least are there security issues?
> Why do you say, that fs can be corrupted? Metadata is still
> journalled, so only data might be corrupted, but FS should still be
> consistent.

Data corruption is still a filesystem corruption.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
