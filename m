Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id D130B6B0088
	for <linux-mm@kvack.org>; Thu, 26 Jun 2014 11:37:02 -0400 (EDT)
Received: by mail-ig0-f173.google.com with SMTP id uq10so862894igb.6
        for <linux-mm@kvack.org>; Thu, 26 Jun 2014 08:37:02 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r3si11760512icl.89.2014.06.26.08.37.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jun 2014 08:37:02 -0700 (PDT)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH 6/6] cfq: Increase default value of target_latency
References: <1403683129-10814-1-git-send-email-mgorman@suse.de>
	<1403683129-10814-7-git-send-email-mgorman@suse.de>
Date: Thu, 26 Jun 2014 11:36:50 -0400
In-Reply-To: <1403683129-10814-7-git-send-email-mgorman@suse.de> (Mel Gorman's
	message of "Wed, 25 Jun 2014 08:58:49 +0100")
Message-ID: <x491tub65t9.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Jens Axboe <axboe@kernel.dk>, Dave Chinner <david@fromorbit.com>

Mel Gorman <mgorman@suse.de> writes:

> The existing CFQ default target_latency results in very poor performance
> for larger numbers of threads doing sequential reads. While this can be
> easily described as a tuning problem for users, it is one that is tricky
> to detect. This patch updates the default to benefit smaller machines.
> Dave Chinner points out that it is dangerous to assume that people know
> how to tune their IO scheduler. Jeff Moyer asked what workloads even
> care about threaded readers but it's reasonable to assume file,
> media, database and multi-user servers all experience large sequential
> readers from multiple sources at the same time.

Right, and I guess I hadn't considered that case as I thought folks used
more than one spinning disk for such workloads.

My main reservation about this change is that you've only provided
numbers for one benchmark.  To bump the default target_latency, ideally
we'd know how it affects other workloads.  However, I'm having a hard
time justifying putting any time into this for a couple of reasons:
1) blk-mq pretty much does away with the i/o scheduler, and that is the
   future
2) there is work in progress to convert cfq into bfq, and that will
   essentially make any effort put into this irrelevant (so it might be
   interesting to test your workload with bfq)

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
