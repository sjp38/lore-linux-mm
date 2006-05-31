Message-ID: <447CF252.7010704@rtr.ca>
Date: Tue, 30 May 2006 21:33:06 -0400
From: Mark Lord <lkml@rtr.ca>
MIME-Version: 1.0
Subject: Re: [rfc][patch] remove racy sync_page?
References: <447AC011.8050708@yahoo.com.au> <20060529121556.349863b8.akpm@osdl.org> <447B8CE6.5000208@yahoo.com.au> <20060529183201.0e8173bc.akpm@osdl.org> <447BB3FD.1070707@yahoo.com.au> <Pine.LNX.4.64.0605292117310.5623@g5.osdl.org> <447BD31E.7000503@yahoo.com.au> <447BD63D.2080900@yahoo.com.au> <Pine.LNX.4.64.0605301041200.5623@g5.osdl.org> <447CE43A.6030700@yahoo.com.au> <Pine.LNX.4.64.0605301739030.24646@g5.osdl.org>
In-Reply-To: <Pine.LNX.4.64.0605301739030.24646@g5.osdl.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mason@suse.com, andrea@suse.de, hugh@veritas.com, axboe@suse.de
List-ID: <linux-mm.kvack.org>

Linus wrote:
> (Yes, tagged queueing makes it less of an issue, of course. I know,

My observations with (S)ATA tagged/native queuing, is that it doesn't make
nearly the difference under Linux that it does under other OSs.
Probably because our block layer is so good at ordering requests,
either from plugging or simply from clever disk scheduling.

> I know. But I _think_ a lot of disks will start seeking for an incoming 
> command the moment they see it, just to get the best latency, rather than 
> wait a millisecond or two to see if they get another request. So even 
> with tagged queuing, the elevator can help, _especially_ for the initial 
> request).

Yup.  Agreed!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
