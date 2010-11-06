Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 507F58D0001
	for <linux-mm@kvack.org>; Sat,  6 Nov 2010 10:35:41 -0400 (EDT)
Received: by iwn9 with SMTP id 9so3947233iwn.14
        for <linux-mm@kvack.org>; Sat, 06 Nov 2010 07:35:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <E1PELiI-0001Pj-8g@approx.mit.edu>
References: <20101105014334.GF13830@dastard> <E1PELiI-0001Pj-8g@approx.mit.edu>
From: dave b <db.pub.mail@gmail.com>
Date: Sun, 7 Nov 2010 01:10:24 +1100
Message-ID: <AANLkTimON_GL6vRF9=_U6oRFQ30EYssx3wv5xdNsU9JM@mail.gmail.com>
Subject: Re: 2.6.36 io bring the system to its knees
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Sanjoy Mahajan <sanjoy@olin.edu>
Cc: Dave Chinner <david@fromorbit.com>, Jesper Juhl <jj@chaosbits.net>, Chris Mason <chris.mason@oracle.com>, Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Aidar Kultayev <the.aidar@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Arjan van de Ven <arjan@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ted Ts'o <tytso@mit.edu>, Corrado Zoccolo <czoccolo@gmail.com>, Shaohua Li <shaohua.li@intel.com>, Steven Barrett <damentz@gmail.com>
List-ID: <linux-mm.kvack.org>

I now personally have thought that this problem is the kernel not
keeping track of reads vs writers properly  or not providing enough
time to reading processes as writing ones which look like they are
blocking the system....

If you want to do a simple test do an unlimited dd  (or two dd's of a
limited size, say 10gb) and a find /
Tell me how it goes :) ( the system will stall)
(obviously stop the dd after some time :) ).

http://article.gmane.org/gmane.linux.kernel.device-mapper.dm-crypt/4561
iirc can reproduce this on plain ext3.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
