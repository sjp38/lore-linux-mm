Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id F37C56B004A
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 03:08:18 -0500 (EST)
Received: by iwn9 with SMTP id 9so492484iwn.14
        for <linux-mm@kvack.org>; Wed, 10 Nov 2010 00:08:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101110013255.GR2715@dastard>
References: <20101105014334.GF13830@dastard>
	<E1PELiI-0001Pj-8g@approx.mit.edu>
	<AANLkTimON_GL6vRF9=_U6oRFQ30EYssx3wv5xdNsU9JM@mail.gmail.com>
	<4CD696B4.6070002@kernel.dk>
	<AANLkTikNPEcwWjEQuC-_=9yH5DCCiwUAY265ggeygcSQ@mail.gmail.com>
	<20101110013255.GR2715@dastard>
Date: Wed, 10 Nov 2010 11:08:17 +0300
Message-ID: <AANLkTikAF=Ka_qB5pPzo9wj_jAp=TG2xSbjaGcoLYfBw@mail.gmail.com>
Subject: Re: 2.6.36 io bring the system to its knees
From: Evgeniy Ivanov <lolkaantimat@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, dave b <db.pub.mail@gmail.com>, Sanjoy Mahajan <sanjoy@olin.edu>, Jesper Juhl <jj@chaosbits.net>, Chris Mason <chris.mason@oracle.com>, Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Aidar Kultayev <the.aidar@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Arjan van de Ven <arjan@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ted Ts'o <tytso@mit.edu>, Corrado Zoccolo <czoccolo@gmail.com>, Shaohua Li <shaohua.li@intel.com>, Steven Barrett <damentz@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 10, 2010 at 4:32 AM, Dave Chinner <david@fromorbit.com> wrote:
> Don't forget to mention data=3Dwriteback is not the default because if
> your system crashes or you lose power running in this mode it will
> *CORRUPT YOUR FILESYSTEM* and you *WILL LOSE DATA*. Not to mention
> the significant security issues (e.g stale data exposure) that also
> occur even if the filesystem is not corrupted by the crash. IOWs,
> data=3Dwriteback is the "fast but I'll eat your data" option for ext3.
>
> So I recommend that nobody follows this path because it only leads
> to worse trouble down the road. =A0Your best bet it to migrate away
> from ext3 to a filesystem that doesn't have such inherent ordering
> problems like ext4 or XFS....

Is it save to use "data=3Dwriteback" with ext4? At least are there
security issues?
Why do you say, that fs can be corrupted? Metadata is still
journalled, so only data might be corrupted, but FS should still be
consistent.


--=20
Evgeniy Ivanov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
