Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id CDCF06B01B6
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 20:30:56 -0400 (EDT)
Message-ID: <4C181AFD.5060503@redhat.com>
Date: Tue, 15 Jun 2010 20:29:49 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 12/12] vmscan: Do not writeback pages in direct reclaim
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>	<1276514273-27693-13-git-send-email-mel@csn.ul.ie>	<4C16A567.4080000@redhat.com>	<20100615114510.GE26788@csn.ul.ie>	<4C17815A.8080402@redhat.com>	<20100615135928.GK26788@csn.ul.ie>	<4C178868.2010002@redhat.com>	<20100615141601.GL26788@csn.ul.ie> <20100616091755.7121c7d3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100616091755.7121c7d3.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 06/15/2010 08:17 PM, KAMEZAWA Hiroyuki wrote:
> On Tue, 15 Jun 2010 15:16:01 +0100
> Mel Gorman<mel@csn.ul.ie>  wrote:

>> But in turn, where is mem_cgroup_hierarchical_reclaim called from direct
>> reclaim? It appears to be only called from the fault path or as a result
>> of the memcg changing size.
>>
> yes. It's only called from
> 	- page fault
> 	- add_to_page_cache()
>
> I think we'll see no stack problem. Now, memcg doesn't wakeup kswapd for
> reclaiming memory, it needs direct writeback.

Of course, a memcg page fault could still be triggered
from copy_to_user or copy_from_user, with a fairly
arbitrary stack frame above...

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
