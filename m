Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id 8FCC36B0035
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 06:50:21 -0500 (EST)
Received: by mail-la0-f50.google.com with SMTP id el20so2585387lab.9
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 03:50:20 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id x7si5305705lag.141.2013.12.10.03.50.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 10 Dec 2013 03:50:20 -0800 (PST)
Message-ID: <52A6FFF0.6080207@parallels.com>
Date: Tue, 10 Dec 2013 15:50:08 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v13 13/16] vmscan: take at least one pass with shrinkers
References: <cover.1386571280.git.vdavydov@parallels.com> <5287164773f8aade33ce17f3c91546c6e1afaf85.1386571280.git.vdavydov@parallels.com> <20131210041826.GB31386@dastard>
In-Reply-To: <20131210041826.GB31386@dastard>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: dchinner@redhat.com, hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, glommer@gmail.com, Glauber Costa <gloomer@openvz.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

On 12/10/2013 08:18 AM, Dave Chinner wrote:
> On Mon, Dec 09, 2013 at 12:05:54PM +0400, Vladimir Davydov wrote:
>> From: Glauber Costa <glommer@openvz.org>
>>
>> In very low free kernel memory situations, it may be the case that we
>> have less objects to free than our initial batch size. If this is the
>> case, it is better to shrink those, and open space for the new workload
>> then to keep them and fail the new allocations.
>>
>> In particular, we are concerned with the direct reclaim case for memcg.
>> Although this same technique can be applied to other situations just as
>> well, we will start conservative and apply it for that case, which is
>> the one that matters the most.
> This should be at the start of the series.

Since Glauber wanted to introduce this only for memcg-reclaim first,
this can't be at the start of the series, but I'll move it to go
immediately after per-memcg shrinking core in the next iteration.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
