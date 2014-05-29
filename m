Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id EEA886B003D
	for <linux-mm@kvack.org>; Thu, 29 May 2014 03:28:44 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kq14so12342380pab.24
        for <linux-mm@kvack.org>; Thu, 29 May 2014 00:28:44 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id hx2si26767832pbb.205.2014.05.29.00.28.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 May 2014 00:28:44 -0700 (PDT)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: virtio ring cleanups, which save stack on older gcc
Date: Thu, 29 May 2014 16:56:41 +0930
Message-Id: <1401348405-18614-1-git-send-email-rusty@rustcorp.com.au>
In-Reply-To: <87oayh6s3s.fsf@rustcorp.com.au>
References: <87oayh6s3s.fsf@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Minchan Kim <minchan@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

They don't make much difference: the easier fix is use gcc 4.8
which drops stack required across virtio block's virtio_queue_rq
down to that kmalloc in virtio_ring from 528 to 392 bytes.

Still, these (*lightly tested*) patches reduce to 432 bytes,
even for gcc 4.6.4.  Posted here FYI.

Cheers,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
