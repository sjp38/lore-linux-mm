Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E49576B004A
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 12:02:42 -0500 (EST)
Received: from mail-iw0-f169.google.com (mail-iw0-f169.google.com [209.85.214.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id oAAH29gC023177
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 09:02:10 -0800
Received: by iwn9 with SMTP id 9so1037029iwn.14
        for <linux-mm@kvack.org>; Wed, 10 Nov 2010 09:02:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTinYZ2wPeeunFv4Ljm+D9SDLbgzTVmw_P9KQdK16@mail.gmail.com>
References: <20101105014334.GF13830@dastard> <E1PELiI-0001Pj-8g@approx.mit.edu>
 <AANLkTimON_GL6vRF9=_U6oRFQ30EYssx3wv5xdNsU9JM@mail.gmail.com>
 <4CD696B4.6070002@kernel.dk> <AANLkTikNPEcwWjEQuC-_=9yH5DCCiwUAY265ggeygcSQ@mail.gmail.com>
 <20101110013255.GR2715@dastard> <AANLkTinpLuzd5c+WqXoa_0Z=nv=mDgd-k4QZbBZHsQnD@mail.gmail.com>
 <AANLkTinYZ2wPeeunFv4Ljm+D9SDLbgzTVmw_P9KQdK16@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 10 Nov 2010 08:55:07 -0800
Message-ID: <AANLkTik1zyrP5DBGC+MmSKF2Eeep3fSu=-8TdOY8BTJj@mail.gmail.com>
Subject: Re: 2.6.36 io bring the system to its knees
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, dave b <db.pub.mail@gmail.com>, Sanjoy Mahajan <sanjoy@olin.edu>, Jesper Juhl <jj@chaosbits.net>, Chris Mason <chris.mason@oracle.com>, Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Aidar Kultayev <the.aidar@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Arjan van de Ven <arjan@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ted Ts'o <tytso@mit.edu>, Corrado Zoccolo <czoccolo@gmail.com>, Shaohua Li <shaohua.li@intel.com>, Steven Barrett <damentz@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 10, 2010 at 8:46 AM, Alexey Dobriyan <adobriyan@gmail.com> wrote:
>>
>> You will lose data even with data=ordered. All the data that didn't
>> get logged before the crash is lost anyway.
>
> Linus, are you using with data=writeback?

I used to, indeed. But since I upgrade computers fairly regularly, and
all the distros have moved towards ext4, I'm no longer using ext3 at
all.

But yes, to me ext3 was totally unusable with rotational media and
"data=ordered". Not just bad. Total crap. Whenever the mail client
wanted to write something out, the whole machine basically stopped.

Of course, part of that was that long ago I used reiserfs back when
SuSE had it as the default. So I didn't think that the hickups were
"normal" like a lot of people probably do. I knew better. So it was
"bad latency, and I know it's the filesystem that is total crap".

> Those of us, who did (without UPS), will never do it again.

Before or after the change to make renaming on top of old files do the
IO flushing?

That made a big difference for some rather common cases.

                            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
