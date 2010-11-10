Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E4A896B004A
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 12:10:20 -0500 (EST)
Received: by yxm8 with SMTP id 8so570741yxm.14
        for <linux-mm@kvack.org>; Wed, 10 Nov 2010 09:10:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTik1zyrP5DBGC+MmSKF2Eeep3fSu=-8TdOY8BTJj@mail.gmail.com>
References: <20101105014334.GF13830@dastard>
	<E1PELiI-0001Pj-8g@approx.mit.edu>
	<AANLkTimON_GL6vRF9=_U6oRFQ30EYssx3wv5xdNsU9JM@mail.gmail.com>
	<4CD696B4.6070002@kernel.dk>
	<AANLkTikNPEcwWjEQuC-_=9yH5DCCiwUAY265ggeygcSQ@mail.gmail.com>
	<20101110013255.GR2715@dastard>
	<AANLkTinpLuzd5c+WqXoa_0Z=nv=mDgd-k4QZbBZHsQnD@mail.gmail.com>
	<AANLkTinYZ2wPeeunFv4Ljm+D9SDLbgzTVmw_P9KQdK16@mail.gmail.com>
	<AANLkTik1zyrP5DBGC+MmSKF2Eeep3fSu=-8TdOY8BTJj@mail.gmail.com>
Date: Wed, 10 Nov 2010 19:10:17 +0200
Message-ID: <AANLkTi=8uwjAqSmMWbAwX1gGbjS8Q8Rh1mPu7RArdLJt@mail.gmail.com>
Subject: Re: 2.6.36 io bring the system to its knees
From: Alexey Dobriyan <adobriyan@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, dave b <db.pub.mail@gmail.com>, Sanjoy Mahajan <sanjoy@olin.edu>, Jesper Juhl <jj@chaosbits.net>, Chris Mason <chris.mason@oracle.com>, Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Aidar Kultayev <the.aidar@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Arjan van de Ven <arjan@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ted Ts'o <tytso@mit.edu>, Corrado Zoccolo <czoccolo@gmail.com>, Shaohua Li <shaohua.li@intel.com>, Steven Barrett <damentz@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 10, 2010 at 6:55 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Wed, Nov 10, 2010 at 8:46 AM, Alexey Dobriyan <adobriyan@gmail.com> wrote:
>> Those of us, who did (without UPS), will never do it again.
>
> Before or after the change to make renaming on top of old files do the
> IO flushing?

It was long ago, so before patch.

> That made a big difference for some rather common cases.

That's good.
Maybe, it's only an order of magnitude likely to lose FS now instead of several.
:-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
