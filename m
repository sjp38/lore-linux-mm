Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id 336186B0037
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 14:38:51 -0400 (EDT)
Received: by mail-qa0-f52.google.com with SMTP id w8so2276295qac.39
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 11:38:50 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id bj7si7452200qcb.8.2014.06.19.11.38.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jun 2014 11:38:50 -0700 (PDT)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH 1/4] cfq: Increase default value of target_latency
References: <1403079807-24690-1-git-send-email-mgorman@suse.de>
	<1403079807-24690-2-git-send-email-mgorman@suse.de>
Date: Thu, 19 Jun 2014 14:38:44 -0400
In-Reply-To: <1403079807-24690-2-git-send-email-mgorman@suse.de> (Mel Gorman's
	message of "Wed, 18 Jun 2014 09:23:24 +0100")
Message-ID: <x49y4wslp6z.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jens Axboe <axboe@kernel.dk>

Mel Gorman <mgorman@suse.de> writes:

> The existing CFQ default target_latency results in very poor performance
> for larger numbers of threads doing sequential reads.  While this can be
> easily described as a tuning problem for users, it is one that is tricky
> to detect. This patch the default on the assumption that people with access
> to expensive fast storage also know how to tune their IO scheduler.
>
> The following is from tiobench run on a mid-range desktop with a single
> spinning disk.
>
>                                       3.16.0-rc1            3.16.0-rc1                 3.0.0
>                                          vanilla          cfq600                     vanilla
> Mean   SeqRead-MB/sec-1         121.88 (  0.00%)      121.60 ( -0.23%)      134.59 ( 10.42%)
> Mean   SeqRead-MB/sec-2         101.99 (  0.00%)      102.35 (  0.36%)      122.59 ( 20.20%)
> Mean   SeqRead-MB/sec-4          97.42 (  0.00%)       99.71 (  2.35%)      114.78 ( 17.82%)
> Mean   SeqRead-MB/sec-8          83.39 (  0.00%)       90.39 (  8.39%)      100.14 ( 20.09%)
> Mean   SeqRead-MB/sec-16         68.90 (  0.00%)       77.29 ( 12.18%)       81.64 ( 18.50%)

Did you test any workloads other than this?  Also, what normal workload
has 8 or more threads doing sequential reads?  (That's an honest
question.)

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
