Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 00FCF6B0088
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 11:07:54 -0500 (EST)
Received: from mail-pv0-f169.google.com (mail-pv0-f169.google.com [74.125.83.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id oAAG7ODR016994
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 08:07:24 -0800
Received: by pvc30 with SMTP id 30so170707pvc.14
        for <linux-mm@kvack.org>; Wed, 10 Nov 2010 08:07:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101110013255.GR2715@dastard>
References: <20101105014334.GF13830@dastard> <E1PELiI-0001Pj-8g@approx.mit.edu>
 <AANLkTimON_GL6vRF9=_U6oRFQ30EYssx3wv5xdNsU9JM@mail.gmail.com>
 <4CD696B4.6070002@kernel.dk> <AANLkTikNPEcwWjEQuC-_=9yH5DCCiwUAY265ggeygcSQ@mail.gmail.com>
 <20101110013255.GR2715@dastard>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 10 Nov 2010 07:59:10 -0800
Message-ID: <AANLkTinpLuzd5c+WqXoa_0Z=nv=mDgd-k4QZbBZHsQnD@mail.gmail.com>
Subject: Re: 2.6.36 io bring the system to its knees
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Jens Axboe <axboe@kernel.dk>, dave b <db.pub.mail@gmail.com>, Sanjoy Mahajan <sanjoy@olin.edu>, Jesper Juhl <jj@chaosbits.net>, Chris Mason <chris.mason@oracle.com>, Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Aidar Kultayev <the.aidar@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Arjan van de Ven <arjan@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ted Ts'o <tytso@mit.edu>, Corrado Zoccolo <czoccolo@gmail.com>, Shaohua Li <shaohua.li@intel.com>, Steven Barrett <damentz@gmail.com>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 9, 2010 at 5:32 PM, Dave Chinner <david@fromorbit.com> wrote:
>
> Don't forget to mention data=writeback is not the default because if
> your system crashes or you lose power running in this mode it will
> *CORRUPT YOUR FILESYSTEM* and you *WILL LOSE DATA*.

You will lose data even with data=ordered. All the data that didn't
get logged before the crash is lost anyway.

So your argument is kind of dishonest. The thing is, if you have a
crash or power outage or whatever, the only data you can really rely
on is always going to be the data that you fsync'ed before the crash.
Everything else is just gravy.

Are there downsides to "data=writeback"? Absolutely. But anybody who
tries to push those downsides without taking the performance and
latency issues into account is just not thinking straight.

Too many people think that "correct" is somehow black-and-white. It's
not. "The correct answer too late" is not worth anything. Sane people
understand that "good enough" is important.

And quite frankly, "data=writeback" is not wonderful, but it's "good
enough". And it helps enormously with at least one class of serious
performance problems. Dismissing it because it doesn't have quite the
guarantees of "data=ordered" is like saying that you should never use
"pi=3.14" for any calculations because it's not as exact as
"pi=3.14159265". The thing is, for many things, three significant
digits (or even _one_ significant digit) is plenty.

ext3 [f]sync sucks. We know. All filesystems suck. They just tend to
do it in different dimensions.

                         Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
