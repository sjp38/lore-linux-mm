Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7A1716B004A
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 13:55:11 -0500 (EST)
Message-ID: <4CDAEA8A.7090002@teksavvy.com>
Date: Wed, 10 Nov 2010 13:55:06 -0500
From: Mark Lord <kernel@teksavvy.com>
MIME-Version: 1.0
Subject: Re: 2.6.36 io bring the system to its knees
References: <20101105014334.GF13830@dastard>	<E1PELiI-0001Pj-8g@approx.mit.edu>	<AANLkTimON_GL6vRF9=_U6oRFQ30EYssx3wv5xdNsU9JM@mail.gmail.com>	<4CD696B4.6070002@kernel.dk>	<AANLkTikNPEcwWjEQuC-_=9yH5DCCiwUAY265ggeygcSQ@mail.gmail.com>	<20101110013255.GR2715@dastard>	<AANLkTinpLuzd5c+WqXoa_0Z=nv=mDgd-k4QZbBZHsQnD@mail.gmail.com>	<AANLkTinYZ2wPeeunFv4Ljm+D9SDLbgzTVmw_P9KQdK16@mail.gmail.com>	<AANLkTik1zyrP5DBGC+MmSKF2Eeep3fSu=-8TdOY8BTJj@mail.gmail.com> <AANLkTi=8uwjAqSmMWbAwX1gGbjS8Q8Rh1mPu7RArdLJt@mail.gmail.com>
In-Reply-To: <AANLkTi=8uwjAqSmMWbAwX1gGbjS8Q8Rh1mPu7RArdLJt@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, dave b <db.pub.mail@gmail.com>, Sanjoy Mahajan <sanjoy@olin.edu>, Jesper Juhl <jj@chaosbits.net>, Chris Mason <chris.mason@oracle.com>, Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Aidar Kultayev <the.aidar@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Arjan van de Ven <arjan@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ted Ts'o <tytso@mit.edu>, Corrado Zoccolo <czoccolo@gmail.com>, Shaohua Li <shaohua.li@intel.com>, Steven Barrett <damentz@gmail.com>
List-ID: <linux-mm.kvack.org>

On 10-11-10 12:10 PM, Alexey Dobriyan wrote:
> On Wed, Nov 10, 2010 at 6:55 PM, Linus Torvalds
> <torvalds@linux-foundation.org>  wrote:
>> On Wed, Nov 10, 2010 at 8:46 AM, Alexey Dobriyan<adobriyan@gmail.com>  wrote:
>>> Those of us, who did (without UPS), will never do it again.

I've used ext2 and ext3 extensively on all of the boxes here,
every since each first became available.   I developed Linux IDE,
the first IDE DMA, lots of custom storage drivers, and more recently
worked on libata drivers.  This meant a LOT of sudden and catastrophic
system failures, as the bugs and other kinks were worked on.

Never lost a nibble.  Totally, utterly reliable stuff for everyday use.
*WITH* the write-caches all enabled on all of the drives, too.

Sure, sudden power-failures could have a better chance of corrupting data,
but those are really rare, and the few that have happened were again non-events 
here.

That's the difference between theory and practice.

Cheers
-ml

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
