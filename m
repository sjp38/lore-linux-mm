Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id CD0626B0078
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 18:01:36 -0400 (EDT)
Received: by bwz17 with SMTP id 17so2082907bwz.14
        for <linux-mm@kvack.org>; Thu, 02 Jun 2011 15:01:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTimvuwLYwzRT-6k_oVwKBzBEo500s-rXETerTskYHfontQ@mail.gmail.com>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
	<1306909519-7286-8-git-send-email-hannes@cmpxchg.org>
	<BANLkTi=cHVZP+fZwHNM3cXVyw53kJ2HQmw@mail.gmail.com>
	<BANLkTimvuwLYwzRT-6k_oVwKBzBEo500s-rXETerTskYHfontQ@mail.gmail.com>
Date: Fri, 3 Jun 2011 07:01:34 +0900
Message-ID: <BANLkTik1X72Re_QKM4iCaPbxCx2kcnfH_w@mail.gmail.com>
Subject: Re: [patch 7/8] vmscan: memcg-aware unevictable page rescue scanner
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

2011/6/3 Ying Han <yinghan@google.com>:
> On Thu, Jun 2, 2011 at 6:27 AM, Hiroyuki Kamezawa
> <kamezawa.hiroyuki@gmail.com> wrote:
>> 2011/6/1 Johannes Weiner <hannes@cmpxchg.org>:
>>> Once the per-memcg lru lists are exclusive, the unevictable page
>>> rescue scanner can no longer work on the global zone lru lists.
>>>
>>> This converts it to go through all memcgs and scan their respective
>>> unevictable lists instead.
>>>
>>> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
>>
>> Hm, isn't it better to have only one GLOBAL LRU for unevictable pages ?
>> memcg only needs counter for unevictable pages and LRU is not necessary
>> to be per memcg because we don't reclaim it...
>
> Hmm. Are we suggesting to keep one un-evictable LRU list for all
> memcgs? So we will have
> exclusive lru only for file and anon. If so, we are not done to make
> all the lru list being exclusive
> which is critical later to improve the zone->lru_lock contention
> across the memcgs
>
considering lrulock, yes, maybe you're right.

> Sorry If i misinterpret the suggestion here
>

My concern is I don't know for what purpose this function is used ..


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
