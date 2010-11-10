Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D0FE46B0087
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 10:03:34 -0500 (EST)
Content-Type: text/plain; charset=UTF-8
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: 2.6.36 io bring the system to its knees
In-reply-to: <20101110145712.GB22073@infradead.org>
References: <20101105014334.GF13830@dastard> <E1PELiI-0001Pj-8g@approx.mit.edu> <AANLkTimON_GL6vRF9=_U6oRFQ30EYssx3wv5xdNsU9JM@mail.gmail.com> <4CD696B4.6070002@kernel.dk> <AANLkTikNPEcwWjEQuC-_=9yH5DCCiwUAY265ggeygcSQ@mail.gmail.com> <20101110013255.GR2715@dastard> <C70A546B-6BC5-49CA-9E34-E69F494A71A0@mit.edu> <20101110145712.GB22073@infradead.org>
Date: Wed, 10 Nov 2010 10:00:36 -0500
Message-Id: <1289401148-sup-3632@think>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Theodore Tso <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>, Linus Torvalds <torvalds@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, dave b <db.pub.mail@gmail.com>, Sanjoy Mahajan <sanjoy@olin.edu>, Jesper Juhl <jj@chaosbits.net>, Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Aidar Kultayev <the.aidar@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Arjan van de Ven <arjan@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Corrado Zoccolo <czoccolo@gmail.com>, Shaohua Li <shaohua.li@intel.com>, Steven Barrett <damentz@gmail.com>
List-ID: <linux-mm.kvack.org>

Excerpts from Christoph Hellwig's message of 2010-11-10 09:57:12 -0500:
> On Wed, Nov 10, 2010 at 09:33:29AM -0500, Theodore Tso wrote:
> > The chance that this occurs using data=writeback in ext4 is much less, BTW, because with delayed allocation we delay updating the inode until right before we write the block.  I have a plan for changing things so that we write the data blocks *first* and then update the metadata blocks second, which will mean that ext4 data=ordered will go away entirely, and we'll get both the safety and as well as avoiding the forced data page writeouts during journal commits.
> 
> That's the scheme used by XFS and btrfs in one form or another.  Chris
> also had a patch to implement it for ext3, which unfortunately fell
> under the floor.

It probably still applies, but by the time I had it stable I realized
that ext4 was really a better place to fix this stuff.  ext3 is what it
is (good and bad), and a big change like my data=guarded code probably
isn't the best way to help.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
