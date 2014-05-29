Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id D4C2B6B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 07:09:10 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id up15so204704pbc.2
        for <linux-mm@kvack.org>; Thu, 29 May 2014 04:09:10 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id g7si431787pat.225.2014.05.29.04.09.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 May 2014 04:09:09 -0700 (PDT)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: virtio ring cleanups, which save stack on older gcc
In-Reply-To: <20140529074117.GI10092@bbox>
References: <87oayh6s3s.fsf@rustcorp.com.au> <1401348405-18614-1-git-send-email-rusty@rustcorp.com.au> <20140529074117.GI10092@bbox>
Date: Thu, 29 May 2014 20:38:33 +0930
Message-ID: <87fvjs7sge.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

Minchan Kim <minchan@kernel.org> writes:
> Hello Rusty,
>
> On Thu, May 29, 2014 at 04:56:41PM +0930, Rusty Russell wrote:
>> They don't make much difference: the easier fix is use gcc 4.8
>> which drops stack required across virtio block's virtio_queue_rq
>> down to that kmalloc in virtio_ring from 528 to 392 bytes.
>> 
>> Still, these (*lightly tested*) patches reduce to 432 bytes,
>> even for gcc 4.6.4.  Posted here FYI.
>
> I am testing with below which was hack for Dave's idea so don't have
> a machine to test your patches until tomorrow.
> So, I will queue your patches into testing machine tomorrow morning.

More interesting would be updating your compiler to 4.8, I think.
Saving <100 bytes on virtio is not going to save you, right?

Cheers,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
