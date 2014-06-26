Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id 64E976B009D
	for <linux-mm@kvack.org>; Thu, 26 Jun 2014 14:04:46 -0400 (EDT)
Received: by mail-qa0-f49.google.com with SMTP id w8so3055396qac.22
        for <linux-mm@kvack.org>; Thu, 26 Jun 2014 11:04:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l10si10403834qad.51.2014.06.26.11.04.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jun 2014 11:04:45 -0700 (PDT)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH 6/6] cfq: Increase default value of target_latency
References: <1403683129-10814-1-git-send-email-mgorman@suse.de>
	<1403683129-10814-7-git-send-email-mgorman@suse.de>
	<x491tub65t9.fsf@segfault.boston.devel.redhat.com>
	<20140626161955.GH10819@suse.de>
	<x49simr4ntz.fsf@segfault.boston.devel.redhat.com>
	<20140626174500.GI10819@suse.de>
Date: Thu, 26 Jun 2014 14:04:34 -0400
In-Reply-To: <20140626174500.GI10819@suse.de> (Mel Gorman's message of "Thu,
	26 Jun 2014 18:45:00 +0100")
Message-ID: <x49k3834kel.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Jens Axboe <axboe@kernel.dk>, Dave Chinner <david@fromorbit.com>

Mel Gorman <mgorman@suse.de> writes:

>> And we should probably run our standard set of I/O exercisers at the
>> very least.  But, like I said, it seems like wasted effort.
>> 
>
> Out of curiousity, what do you consider to be the standard set of I/O
> exercisers?

Yes, that was vague, sorry.  I was referring to any io generator that
will perform sequential and random I/O (writes, re-writes, reads, random
writes, random reads, strided reads, backwards reads, etc).  We use
iozone internally, testing both buffered and direct I/O, varying file
and record sizes and across multiple file systems.  Data sets that fall
inside of the page cache tend to have a high standard deviation, so, as
an I/O guy, I ignore those.  ;-)

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
