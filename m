Message-ID: <447D923B.1080503@rtr.ca>
Date: Wed, 31 May 2006 08:55:23 -0400
From: Mark Lord <lkml@rtr.ca>
MIME-Version: 1.0
Subject: Re: [rfc][patch] remove racy sync_page?
References: <447B8CE6.5000208@yahoo.com.au> <20060529183201.0e8173bc.akpm@osdl.org> <447BB3FD.1070707@yahoo.com.au> <Pine.LNX.4.64.0605292117310.5623@g5.osdl.org> <447BD31E.7000503@yahoo.com.au> <447BD63D.2080900@yahoo.com.au> <Pine.LNX.4.64.0605301041200.5623@g5.osdl.org> <447CE43A.6030700@yahoo.com.au> <Pine.LNX.4.64.0605301739030.24646@g5.osdl.org> <447CF252.7010704@rtr.ca> <20060531061110.GB29535@suse.de>
In-Reply-To: <20060531061110.GB29535@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <axboe@suse.de>
Cc: Linus Torvalds <torvalds@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mason@suse.com, andrea@suse.de, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Jens Axboe wrote:
>
> NCQ helps us with something we can never fix in software - the
> rotational latency. Ordering is only a small part of the picture.

Yup.  And it also helps reduce the command-to-command latencies.

I'm all for it, and have implemented tagged queuing for a variety
of device drivers over the past five years (TCQ & NCQ).  In every
case people say.. wow, I expected more of a difference than that,
while still noting the end result was faster under Linux than MS$.

Of course with artificial benchmarks, and the right firmware in
the right drives, it's easier to create and see a difference.
But I'm talking more life-like loads than just a multi-threaded
random seek generator.

Cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
