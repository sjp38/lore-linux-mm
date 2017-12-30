Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1EA146B0038
	for <linux-mm@kvack.org>; Sat, 30 Dec 2017 17:40:37 -0500 (EST)
Received: by mail-yb0-f200.google.com with SMTP id a17so108750ybl.0
        for <linux-mm@kvack.org>; Sat, 30 Dec 2017 14:40:37 -0800 (PST)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id g130si7728496ywh.14.2017.12.30.14.40.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 30 Dec 2017 14:40:36 -0800 (PST)
Date: Sat, 30 Dec 2017 17:40:28 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: About the try to remove cross-release feature entirely by Ingo
Message-ID: <20171230224028.GC3366@thunk.org>
References: <CANrsvRPQcWz-p_3TYfNf+Waek3bcNNPniXhFzyyS=7qbCqzGyg@mail.gmail.com>
 <20171229014736.GA10341@X58A-UD3R>
 <20171229035146.GA11757@thunk.org>
 <20171229072851.GA12235@X58A-UD3R>
 <20171230061624.GA27959@bombadil.infradead.org>
 <20171230154041.GB3366@thunk.org>
 <20171230204417.GF27959@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171230204417.GF27959@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Byungchul Park <byungchul.park@lge.com>, Byungchul Park <max.byungchul.park@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, david@fromorbit.com, Linus Torvalds <torvalds@linux-foundation.org>, Amir Goldstein <amir73il@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, oleg@redhat.com, kernel-team@lge.com, daniel@ffwll.ch

On Sat, Dec 30, 2017 at 12:44:17PM -0800, Matthew Wilcox wrote:
> 
> I'm not sure I agree with this part.  What if we add a new TCP lock class
> for connections which are used for filesystems/network block devices/...?
> Yes, it'll be up to each user to set the lockdep classification correctly,
> but that's a relatively small number of places to add annotations,
> and I don't see why it wouldn't work.

I was exagerrating a bit for effect, I admit.  (but only a bit).

It can probably be for all TCP connections that are used by kernel
code (as opposed to userspace-only TCP connections).  But it would
probably have to be each and every device-mapper instance, each and
every block device, each and every mounted file system, each and every
bdi object, etc.

The point I was trying to drive home is that "all we have to do is
just classify everything well or just invalidate the right lock
objects" is a massive understatement of the complexity level of what
would be required, or the number of locks/completion handlers that
would have to be blacklisted.

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
