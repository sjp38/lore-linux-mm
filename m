Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 638516B002D
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 18:42:51 -0400 (EDT)
Message-ID: <4E8F8062.2080105@redhat.com>
Date: Fri, 07 Oct 2011 18:42:42 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm: Abort reclaim/compaction if compaction can proceed
References: <1318000643-27996-1-git-send-email-mgorman@suse.de> <1318000643-27996-3-git-send-email-mgorman@suse.de> <4E8F5BEA.3040502@redhat.com> <20111007202417.GD6418@suse.de>
In-Reply-To: <20111007202417.GD6418@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>, akpm@linux-foundation.org, Josh Boyer <jwboyer@redhat.com>, aarcange@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 10/07/2011 04:24 PM, Mel Gorman wrote:
> On Fri, Oct 07, 2011 at 04:07:06PM -0400, Rik van Riel wrote:
>> On 10/07/2011 11:17 AM, Mel Gorman wrote:
>>> If compaction can proceed, shrink_zones() stops doing any work but
>>> the callers still shrink_slab(), raises the priority and potentially
>>> sleeps.  This patch aborts direct reclaim/compaction entirely if
>>> compaction can proceed.
>>>
>>> Signed-off-by: Mel Gorman<mgorman@suse.de>
>>
>> This patch makes sense to me, but I have not tested it like
>> the first one.
>>
>
> Do if you can.

I'll probably build a kernel with your patch in it on
Sunday - I'll be walking across a mountain tomorrow :)

> It's marginal and could be confirmation bias on my part. Basically,
> there is noise when this path is being exercised but there were fewer
> slabs scanned.  However, I don't know what the variances are and
> whether the reduction was within the noise or not but it makes sense
> that it would scan less.  If I profiled carefully, I might be able
> to show that a few additional cycles are spent raising the priority
> but it would be marginal.

This seems clear enough.

> While patch 1 is very clear, patch 2 depends on reviewers deciding it
> "makes sense".
>
>> Having said that, I'm pretty sure the patch is ok :)
>>
>
> Care to ack?

Sure.

Acked-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
