Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f176.google.com (mail-ea0-f176.google.com [209.85.215.176])
	by kanga.kvack.org (Postfix) with ESMTP id 20AA16B0036
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 18:27:01 -0500 (EST)
Received: by mail-ea0-f176.google.com with SMTP id h14so1271590eaj.7
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 15:27:00 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id 43si4834926eeh.94.2014.01.24.15.26.58
        for <linux-mm@kvack.org>;
        Fri, 24 Jan 2014 15:26:59 -0800 (PST)
Message-ID: <52E2F6B7.3050304@redhat.com>
Date: Fri, 24 Jan 2014 18:26:47 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 0/2] mm: reduce reclaim stalls with heavy anon and dirty
 cache
References: <1390600984-13925-1-git-send-email-hannes@cmpxchg.org> <20140124143003.2629e9c2c8c2595e805c8c25@linux-foundation.org> <20140124225156.GG4407@cmpxchg.org>
In-Reply-To: <20140124225156.GG4407@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 01/24/2014 05:51 PM, Johannes Weiner wrote:
> On Fri, Jan 24, 2014 at 02:30:03PM -0800, Andrew Morton wrote:
>> On Fri, 24 Jan 2014 17:03:02 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:
>>
>>> Tejun reported stuttering and latency spikes on a system where random
>>> tasks would enter direct reclaim and get stuck on dirty pages.  Around
>>> 50% of memory was occupied by tmpfs backed by an SSD, and another disk
>>> (rotating) was reading and writing at max speed to shrink a partition.
>>
>> Do you think this is serious enough to squeeze these into 3.14?
> 
> We have been biasing towards cache reclaim at least as far back as the
> LRU split and we always considered anon dirtyable, so it's not really
> a *new* problem.  And there is a chance of regressing write bandwidth
> for certain workloads by effectively shrinking their dirty limit -
> although that is easily fixed by changing dirty_ratio.
> 
> On the other hand, the stuttering is pretty nasty (could reproduce it
> locally too) and the workload is not exactly esoteric.  Plus, I'm not
> sure if waiting will increase the test exposure.
> 
> So 3.14 would work for me, unless Mel and Rik have concerns.

3.14 would be fine, indeed.

On the other hand, if there are enough user reports of the stuttering
problem on older kernels, a -stable backport could be appropriate
too...

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
