Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3168A6B0011
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 19:18:58 -0400 (EDT)
Received: by wwi18 with SMTP id 18so3835887wwi.2
        for <linux-mm@kvack.org>; Wed, 27 Apr 2011 16:18:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110427170304.d31c1398.kamezawa.hiroyu@jp.fujitsu.com>
References: <cover.1303833415.git.minchan.kim@gmail.com>
	<232562452317897b5acb1445803410d74233a923.1303833417.git.minchan.kim@gmail.com>
	<20110427170304.d31c1398.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 28 Apr 2011 08:18:54 +0900
Message-ID: <BANLkTik9c7MVoHH+hjn7SHqMhW-6d4eoLg@mail.gmail.com>
Subject: Re: [RFC 3/8] vmscan: make isolate_lru_page with filter aware
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

On Wed, Apr 27, 2011 at 5:03 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 27 Apr 2011 01:25:20 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> In some __zone_reclaim case, we don't want to shrink mapped page.
>> Nonetheless, we have isolated mapped page and re-add it into
>> LRU's head. It's unnecessary CPU overhead and makes LRU churning.
>>
>> Of course, when we isolate the page, the page might be mapped but
>> when we try to migrate the page, the page would be not mapped.
>> So it could be migrated. But race is rare and although it happens,
>> it's no big deal.
>>
>> Cc: Christoph Lameter <cl@linux.com>
>> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Cc: Mel Gorman <mgorman@suse.de>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>
>
> Hmm, it seems mm/memcontrol.c::mem_cgroup_isolate_pages() should be updated, too.
>
> But it's okay you start from global LRU.

Yes. That's exactly what  I want. :)
I am supposed to consider memcg after concept is approved.

>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Thanks fore the review, Kame.
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
