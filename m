Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 36E006B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 07:09:11 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id ey11so202219pad.4
        for <linux-mm@kvack.org>; Thu, 29 May 2014 04:09:10 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id bz3si457461pbd.157.2014.05.29.04.09.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 May 2014 04:09:09 -0700 (PDT)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 4/4] virtio_ring: unify direct/indirect code paths.
In-Reply-To: <20140529075256.GZ30445@twins.programming.kicks-ass.net>
References: <87oayh6s3s.fsf@rustcorp.com.au> <1401348405-18614-1-git-send-email-rusty@rustcorp.com.au> <1401348405-18614-5-git-send-email-rusty@rustcorp.com.au> <20140529075256.GZ30445@twins.programming.kicks-ass.net>
Date: Thu, 29 May 2014 20:35:58 +0930
Message-ID: <87iooo7skp.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Minchan Kim <minchan@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

Peter Zijlstra <peterz@infradead.org> writes:
> On Thu, May 29, 2014 at 04:56:45PM +0930, Rusty Russell wrote:
>> Before:
>> 	gcc 4.8.2: virtio_blk: stack used = 392
>> 	gcc 4.6.4: virtio_blk: stack used = 480
>> 
>> After:
>> 	gcc 4.8.2: virtio_blk: stack used = 408
>> 	gcc 4.6.4: virtio_blk: stack used = 432
>
> Is it worth it to make the good compiler worse? People are going to use
> the newer GCC more as time goes on anyhow.

No, but it's only 16 bytes of stack loss for a simplicity win:

 virtio_ring.c |  120 +++++++++++++++++++++-------------------------------------
 1 file changed, 45 insertions(+), 75 deletions(-)

Cheers,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
