Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 783FA6B0033
	for <linux-mm@kvack.org>; Thu,  4 Jul 2013 10:25:05 -0400 (EDT)
Message-ID: <51D585A8.3070001@redhat.com>
Date: Thu, 04 Jul 2013 10:24:40 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 07/13] sched: Split accounting of NUMA hinting faults
 that pass two-stage filter
References: <1372861300-9973-1-git-send-email-mgorman@suse.de> <1372861300-9973-8-git-send-email-mgorman@suse.de> <20130703215654.GN17812@cmpxchg.org> <20130704092356.GK1875@suse.de>
In-Reply-To: <20130704092356.GK1875@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 07/04/2013 05:23 AM, Mel Gorman wrote:

> I think that dealing with this specific problem is a series all on its
> own and treating it on its own in isolation would be best.

Agreed, lets tackle one thing at a time, otherwise we will
(once again) end up with a patch series that is too large
to merge.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
