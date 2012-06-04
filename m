Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id B405E6B005C
	for <linux-mm@kvack.org>; Sun,  3 Jun 2012 20:26:05 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id D206C3EE0BC
	for <linux-mm@kvack.org>; Mon,  4 Jun 2012 09:26:03 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B7C1F45DEB4
	for <linux-mm@kvack.org>; Mon,  4 Jun 2012 09:26:03 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9DF3E45DE7E
	for <linux-mm@kvack.org>; Mon,  4 Jun 2012 09:26:03 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8ACEE1DB803E
	for <linux-mm@kvack.org>; Mon,  4 Jun 2012 09:26:03 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 419D71DB8042
	for <linux-mm@kvack.org>; Mon,  4 Jun 2012 09:26:03 +0900 (JST)
Message-ID: <4FCC0020.5080801@jp.fujitsu.com>
Date: Mon, 04 Jun 2012 09:24:00 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] rename MEM_CGROUP_STAT_SWAPOUT as MEM_CGROUP_STAT_NR_SWAP
References: <4FC89BC4.9030604@jp.fujitsu.com> <20120601165320.GA1761@cmpxchg.org> <alpine.LSU.2.00.1206011047430.9814@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1206011047430.9814@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, mhocko@suse.cz, akpm@linux-foundation.org

(2012/06/02 2:54), Hugh Dickins wrote:
> On Fri, 1 Jun 2012, Johannes Weiner wrote:
>> On Fri, Jun 01, 2012 at 07:39:00PM +0900, Kamezawa Hiroyuki wrote:
>>> MEM_CGROUP_STAT_SWAPOUT represents the usage of swap rather than
>>> the number of swap-out events. Rename it to be MEM_CGROUP_STAT_NR_SWAP.
>>>
>>> Signed-off-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
>>
>> Wouldn't MEM_CGROUP_STAT_SWAP be better?  It's equally descriptive but
>> matches the string.  And we also don't have NR_ for cache, rss, mapped
>> file etc.
>
> That's just what I thought too.
>
> You can attach Acked-by: Hugh Dickins<hughd@google.com>
> to MEM_CGROUP_STAT_SWAP and MEM_CGROUP_CHARGE_TYPE_ANON.
>
> Oh, and to a patch deleting MEM_CGROUP_CHARGE_TYPE_FORCE!
>
Sure, I'll prepare v2.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
