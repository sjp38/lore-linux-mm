Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 130576B0085
	for <linux-mm@kvack.org>; Sun,  7 Nov 2010 10:57:38 -0500 (EST)
Received: from mail-iw0-f169.google.com (mail-iw0-f169.google.com [209.85.214.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id oA7FvZ1h022328
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Sun, 7 Nov 2010 07:57:35 -0800
Received: by iwn9 with SMTP id 9so5007056iwn.14
        for <linux-mm@kvack.org>; Sun, 07 Nov 2010 07:57:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4CD696B4.6070002@kernel.dk>
References: <20101105014334.GF13830@dastard> <E1PELiI-0001Pj-8g@approx.mit.edu>
 <AANLkTimON_GL6vRF9=_U6oRFQ30EYssx3wv5xdNsU9JM@mail.gmail.com> <4CD696B4.6070002@kernel.dk>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 7 Nov 2010 07:50:13 -0800
Message-ID: <AANLkTikNPEcwWjEQuC-_=9yH5DCCiwUAY265ggeygcSQ@mail.gmail.com>
Subject: Re: 2.6.36 io bring the system to its knees
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Jens Axboe <axboe@kernel.dk>
Cc: dave b <db.pub.mail@gmail.com>, Sanjoy Mahajan <sanjoy@olin.edu>, Dave Chinner <david@fromorbit.com>, Jesper Juhl <jj@chaosbits.net>, Chris Mason <chris.mason@oracle.com>, Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Aidar Kultayev <the.aidar@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Arjan van de Ven <arjan@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ted Ts'o <tytso@mit.edu>, Corrado Zoccolo <czoccolo@gmail.com>, Shaohua Li <shaohua.li@intel.com>, Steven Barrett <damentz@gmail.com>
List-ID: <linux-mm.kvack.org>

On Sun, Nov 7, 2010 at 4:08 AM, Jens Axboe <axboe@kernel.dk> wrote:
>
> As already mentioned, ext3 is just not a good choice for this sort of
> thing. Did you have atimes enabled?

At least for ext3, more important than atimes is the "data=writeback"
setting. Especially since our atime default is sane these days (ie if
you don't specify anything, we end up using 'relatime').

If you compile your own kernel, answer "N" to the question

  Default to 'data=ordered' in ext3?

at config time (CONFIG_EXT3_DEFAULTS_TO_ORDERED), or you can make sure
"data=writeback" is in the fstab (but I don't think everything honors
it for the root filesystem).

                                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
