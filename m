Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0C4F16B0087
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 17:27:31 -0500 (EST)
Received: by iwn1 with SMTP id 1so2479974iwn.37
        for <linux-mm@kvack.org>; Wed, 08 Dec 2010 14:25:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101208164327.GL2356@cmpxchg.org>
References: <1291734086-1405-1-git-send-email-minchan.kim@gmail.com>
	<20101208164327.GL2356@cmpxchg.org>
Date: Thu, 9 Dec 2010 07:25:18 +0900
Message-ID: <AANLkTi=93QLYaO9gktVPxu_4gD9sV1tUPL9duj7RqL0X@mail.gmail.com>
Subject: Re: [PATCH] compaction: Remove mem_cgroup_del_lru
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 9, 2010 at 1:43 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Wed, Dec 08, 2010 at 12:01:26AM +0900, Minchan Kim wrote:
>> del_page_from_lru_list alreay called mem_cgroup_del_lru.
>> So we need to call it again. It makes wrong stat of memcg and
>> even happen VM_BUG_ON hit.
>>
>> Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
>> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> Cc: Mel Gorman <mel@csn.ul.ie>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>
> Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>
>
> But regarding the severity of this: shouldn't the second deletion
> attempt be caught by the TestClearPageCgroupAcctLRU() early in
> mem_cgroup_del_lru_list()?
>

Right, I missed that.
Andrew, I will resend modified description.

Thanks for careful review again, Hannes.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
