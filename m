Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A75A36B0012
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 19:42:31 -0400 (EDT)
Received: by wwi36 with SMTP id 36so2113303wwi.26
        for <linux-mm@kvack.org>; Wed, 27 Apr 2011 16:42:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110427171505.5d7bf485.kamezawa.hiroyu@jp.fujitsu.com>
References: <cover.1303833415.git.minchan.kim@gmail.com>
	<2b79bbf9ddceb73624f49bbe9477126147d875fd.1303833417.git.minchan.kim@gmail.com>
	<20110427171505.5d7bf485.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 28 Apr 2011 08:42:28 +0900
Message-ID: <BANLkTim8B7R_9jtBOLS6F_OYJJMwgcG-0Q@mail.gmail.com>
Subject: Re: [RFC 5/8] compaction: remove active list counting
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

On Wed, Apr 27, 2011 at 5:15 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 27 Apr 2011 01:25:22 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> acct_isolated of compaction uses page_lru_base_type which returns only
>> base type of LRU list so it never returns LRU_ACTIVE_ANON or LRU_ACTIVE_FILE.
>> So it's pointless to add lru[LRU_ACTIVE_[ANON|FILE]] to get sum.
>>
>> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Cc: Mel Gorman <mgorman@suse.de>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>
> I think some comments are necessary to explain why INACTIVE only.

As alternative, I can change page_lru_base_type with page_lru.
It's not hot path so I will do.

Thanks, Kame.

> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
