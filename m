Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 6A4366B004D
	for <linux-mm@kvack.org>; Wed, 16 May 2012 04:30:29 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id EDB753EE0C7
	for <linux-mm@kvack.org>; Wed, 16 May 2012 17:30:27 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CF85445DE4D
	for <linux-mm@kvack.org>; Wed, 16 May 2012 17:30:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id AC66C45DE61
	for <linux-mm@kvack.org>; Wed, 16 May 2012 17:30:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F3FE1DB802F
	for <linux-mm@kvack.org>; Wed, 16 May 2012 17:30:27 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C7161DB803F
	for <linux-mm@kvack.org>; Wed, 16 May 2012 17:30:27 +0900 (JST)
Message-ID: <4FB3652D.2040909@jp.fujitsu.com>
Date: Wed, 16 May 2012 17:28:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 2/2] decrement static keys on real destroy time
References: <1336767077-25351-1-git-send-email-glommer@parallels.com> <1336767077-25351-3-git-send-email-glommer@parallels.com> <4FB058D8.6060707@jp.fujitsu.com> <4FB3431C.3050402@parallels.com> <4FB3518B.3090205@parallels.com>
In-Reply-To: <4FB3518B.3090205@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, netdev@vger.kernel.org, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>

(2012/05/16 16:04), Glauber Costa wrote:

> On 05/16/2012 10:03 AM, Glauber Costa wrote:
>>> BTW, what is the relationship between 1/2 and 2/2  ?
>> Can't do jump label patching inside an interrupt handler. They need to
>> happen when we free the structure, and I was about to add a worker
>> myself when I found out we already have one: just we don't always use it.
>>
>> Before we merge it, let me just make sure the issue with config Li
>> pointed out don't exist. I did test it, but since I've reposted this
>> many times with multiple tiny changes - the type that will usually get
>> us killed, I'd be more comfortable with an extra round of testing if
>> someone spotted a possibility.
>>
>> Who is merging this fix, btw ?
>> I find it to be entirely memcg related, even though it touches a file in
>> net (but a file with only memcg code in it)
>>
> 
> For the record, I compiled test it many times, and the problem that Li
> wondered about seems not to exist.
> 

Ah...Hmm.....I guess dependency problem will be found in -mm if any rather than
netdev...

David, can this bug-fix patch goes via -mm tree ? Or will you pick up ?

CC'ed David Miller and Andrew Morton.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
