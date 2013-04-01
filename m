Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 8AF226B0002
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 05:36:17 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id CC7AB3EE0C7
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 18:36:15 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A7BC945DE53
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 18:36:15 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 32D2B45DE4F
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 18:36:15 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D03F1DB8045
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 18:36:15 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C91AC1DB803F
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 18:36:14 +0900 (JST)
Message-ID: <515954F3.3030703@jp.fujitsu.com>
Date: Mon, 01 Apr 2013 18:35:47 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 26/28] memcg: per-memcg kmem shrinking
References: <1364548450-28254-1-git-send-email-glommer@parallels.com> <1364548450-28254-27-git-send-email-glommer@parallels.com> <515945E3.9090809@jp.fujitsu.com> <515949EB.7020400@parallels.com> <51594CED.4050401@jp.fujitsu.com>
In-Reply-To: <51594CED.4050401@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Shrinnker <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, hughd@google.com, yinghan@google.com, Dave Chinner <dchinner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

(2013/04/01 18:01), Kamezawa Hiroyuki wrote:
> (2013/04/01 17:48), Glauber Costa wrote:
>>>> +static int memcg_try_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
>>>> +{
>>>> +	int retries = MEM_CGROUP_RECLAIM_RETRIES;
>>>
>>> I'm not sure this retry numbers, for anon/file LRUs is suitable for kmem.
>>>
>> Suggestions ?
>>
> 
> I think you did tests.

sorry..

I think you did tests and know what number is good by tests.
If it's the same number to MEM_CGROUP_RECLAIM_RETRIES, I have no objections.
I think no reason is bad.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
