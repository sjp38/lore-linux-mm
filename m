Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 2EBA26B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 17:42:45 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id rq2so2330223pbb.35
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 14:42:44 -0700 (PDT)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:5])
        by mx.google.com with ESMTP id hr5si7276802pad.89.2014.06.19.14.42.43
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 14:42:44 -0700 (PDT)
Date: Fri, 20 Jun 2014 07:42:14 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 1/4] cfq: Increase default value of target_latency
Message-ID: <20140619214214.GM4453@dastard>
References: <1403079807-24690-1-git-send-email-mgorman@suse.de>
 <1403079807-24690-2-git-send-email-mgorman@suse.de>
 <x49y4wslp6z.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <x49y4wslp6z.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jens Axboe <axboe@kernel.dk>

On Thu, Jun 19, 2014 at 02:38:44PM -0400, Jeff Moyer wrote:
> Mel Gorman <mgorman@suse.de> writes:
> 
> > The existing CFQ default target_latency results in very poor performance
> > for larger numbers of threads doing sequential reads.  While this can be
> > easily described as a tuning problem for users, it is one that is tricky
> > to detect. This patch the default on the assumption that people with access
> > to expensive fast storage also know how to tune their IO scheduler.
> >
> > The following is from tiobench run on a mid-range desktop with a single
> > spinning disk.
> >
> >                                       3.16.0-rc1            3.16.0-rc1                 3.0.0
> >                                          vanilla          cfq600                     vanilla
> > Mean   SeqRead-MB/sec-1         121.88 (  0.00%)      121.60 ( -0.23%)      134.59 ( 10.42%)
> > Mean   SeqRead-MB/sec-2         101.99 (  0.00%)      102.35 (  0.36%)      122.59 ( 20.20%)
> > Mean   SeqRead-MB/sec-4          97.42 (  0.00%)       99.71 (  2.35%)      114.78 ( 17.82%)
> > Mean   SeqRead-MB/sec-8          83.39 (  0.00%)       90.39 (  8.39%)      100.14 ( 20.09%)
> > Mean   SeqRead-MB/sec-16         68.90 (  0.00%)       77.29 ( 12.18%)       81.64 ( 18.50%)
> 
> Did you test any workloads other than this?  Also, what normal workload
> has 8 or more threads doing sequential reads?  (That's an honest
> question.)

I'd also suggest that making changes basd on the assumption that
people affected by the change know how to tune CFQ is a bad idea.
When CFQ misbehaves, most people just switch to deadline or no-op
because they don't understand how CFQ works, nor what what all the
nobs do or which ones to tweak to solve their problem....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
