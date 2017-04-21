Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id C32062806D2
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 13:52:31 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id z63so145146916ioz.23
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 10:52:31 -0700 (PDT)
Received: from mail-io0-x242.google.com (mail-io0-x242.google.com. [2607:f8b0:4001:c06::242])
        by mx.google.com with ESMTPS id o73si11945558iod.239.2017.04.21.10.52.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 10:52:30 -0700 (PDT)
Received: by mail-io0-x242.google.com with SMTP id d203so32954828iof.2
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 10:52:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170420143033.3nzi6nruqd5s3n7f@techsingularity.net>
References: <20170420110042.73d01e0f@redhat.com> <20170420143033.3nzi6nruqd5s3n7f@techsingularity.net>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 21 Apr 2017 10:52:29 -0700
Message-ID: <CA+55aFznH8Y9_okyQ=dU1AeJL8rtHx=n5DqT3sGJj7kr6QMYXA@mail.gmail.com>
Subject: Re: Heads-up: two regressions in v4.11-rc series
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, Tariq Toukan <tariqt@mellanox.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>

On Thu, Apr 20, 2017 at 7:30 AM, Mel Gorman <mgorman@techsingularity.net> wrote:
>> The end result was a revert, and this is waiting in AKPMs quilt queue:
>>  http://ozlabs.org/~akpm/mmots/broken-out/revert-mm-page_alloc-only-use-per-cpu-allocator-for-irq-safe-requests.patch
>>
>
> This was flagged to Andrew that it should go in for either 4.11 or if
> there were concerns about how close to the release we are then put it in
> for 4.11-stable. At worst, I can do a resubmit to -stable myself after
> it gets merged in the next window if it falls between the cracks.

This got merged (commit d34b0733b452: "Revert "mm, page_alloc: only
use per-cpu allocator for irq-safe requests"").

The other issue (caused by commit a499a5a14dbd: "sched/cputime:
Increment kcpustat directly on irqtime account") is still open.

Frederic? Revert? But I guess it's something we can delay for
backporting, it's presumably not possible to hit maliciously except on
some fast local network attacker just causing an effective DoS.

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
