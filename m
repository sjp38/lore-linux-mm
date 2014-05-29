Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f169.google.com (mail-vc0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id B46626B0038
	for <linux-mm@kvack.org>; Thu, 29 May 2014 11:39:12 -0400 (EDT)
Received: by mail-vc0-f169.google.com with SMTP id ij19so594184vcb.0
        for <linux-mm@kvack.org>; Thu, 29 May 2014 08:39:12 -0700 (PDT)
Received: from mail-vc0-x235.google.com (mail-vc0-x235.google.com [2607:f8b0:400c:c03::235])
        by mx.google.com with ESMTPS id pq7si752337vec.83.2014.05.29.08.39.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 May 2014 08:39:12 -0700 (PDT)
Received: by mail-vc0-f181.google.com with SMTP id hy4so571274vcb.40
        for <linux-mm@kvack.org>; Thu, 29 May 2014 08:39:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1401348405-18614-2-git-send-email-rusty@rustcorp.com.au>
References: <87oayh6s3s.fsf@rustcorp.com.au>
	<1401348405-18614-1-git-send-email-rusty@rustcorp.com.au>
	<1401348405-18614-2-git-send-email-rusty@rustcorp.com.au>
Date: Thu, 29 May 2014 08:39:11 -0700
Message-ID: <CA+55aFzybuwti5z=uGXxibLqyDwQpPE88bN4cL5YQwpfb7aMbw@mail.gmail.com>
Subject: Re: [PATCH 1/4] Hack: measure stack taken by vring from virtio_blk
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Minchan Kim <minchan@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

On Thu, May 29, 2014 at 12:26 AM, Rusty Russell <rusty@rustcorp.com.au> wrote:
> Results (x86-64, Minchan's .config):
>
> gcc 4.8.2: virtio_blk: stack used = 392
> gcc 4.6.4: virtio_blk: stack used = 528

I wonder if that's just random luck (although 35% more stack use seems
to be bigger than "random" - that's quite a big difference), or
whether the gcc guys are aware of having fixed some major stack spill
issue.

But yeah, Minchan uses gcc 4.6.3 according to one of his emails, so
_part_ of his stack smashing is probably due to compiler version.

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
