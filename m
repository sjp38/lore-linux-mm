Message-ID: <3DDA17D2.4020004@cyberone.com.au>
Date: Tue, 19 Nov 2002 21:52:02 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: 2.5.48-mm1
References: <3DDA0153.A1971C76@digeo.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Jens Axboe <axboe@suse.de>
List-ID: <linux-mm.kvack.org>


Andrew Morton wrote:

>url: http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.48/2.5.48-mm1/
>
snip

>
>
>Since 2.5.47-mm3:
>
snip

>+np-deadline.patch
>
> Deadline scheduler work from Nick Piggin
>
snip

This may degrade IO read latency a little bit and will
still be suboptimal when there are both read and write
requests outstanding for some io patterns (no worse than
47-mm3). Jens and I have been making progress here however.

Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
