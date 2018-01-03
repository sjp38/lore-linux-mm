Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 627436B02F9
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 02:06:03 -0500 (EST)
Received: by mail-yb0-f199.google.com with SMTP id q204so272358ybg.23
        for <linux-mm@kvack.org>; Tue, 02 Jan 2018 23:06:03 -0800 (PST)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id w6si103347ywj.232.2018.01.02.23.06.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 02 Jan 2018 23:06:02 -0800 (PST)
Date: Wed, 3 Jan 2018 02:05:56 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: About the try to remove cross-release feature entirely by Ingo
Message-ID: <20180103070556.GA22583@thunk.org>
References: <CANrsvRPQcWz-p_3TYfNf+Waek3bcNNPniXhFzyyS=7qbCqzGyg@mail.gmail.com>
 <20171229014736.GA10341@X58A-UD3R>
 <20171229035146.GA11757@thunk.org>
 <20171229072851.GA12235@X58A-UD3R>
 <20171230061624.GA27959@bombadil.infradead.org>
 <20171230154041.GB3366@thunk.org>
 <20171230204417.GF27959@bombadil.infradead.org>
 <20171230224028.GC3366@thunk.org>
 <f2bc220a-a363-122a-dbf9-e5416c550899@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f2bc220a-a363-122a-dbf9-e5416c550899@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: Matthew Wilcox <willy@infradead.org>, Byungchul Park <max.byungchul.park@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, david@fromorbit.com, Linus Torvalds <torvalds@linux-foundation.org>, Amir Goldstein <amir73il@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, oleg@redhat.com, kernel-team@lge.com, daniel@ffwll.ch

On Wed, Jan 03, 2018 at 11:10:37AM +0900, Byungchul Park wrote:
> > The point I was trying to drive home is that "all we have to do is
> > just classify everything well or just invalidate the right lock
> 
> Just to be sure, we don't have to invalidate lock objects at all but
> a problematic waiter only.

So essentially you are proposing that we have to play "whack-a-mole"
as we find false positives, and where we may have to put in ad-hoc
plumbing to only invalidate "a problematic waiter" when it's
problematic --- or to entirely suppress the problematic waiter
altogether.  And in that case, a file system developer might be forced
to invalidate a lock/"waiter"/"completion" in another subsystem.

I will also remind you that doing this will trigger a checkpatch.pl
*error*:

ERROR("LOCKDEP", "lockdep_no_validate class is reserved for device->mutex.\n" . $herecurr);

	 		      	       		- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
