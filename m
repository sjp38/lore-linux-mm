Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 0D0B06B0291
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 00:47:46 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 5BB613EE0BB
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 13:47:45 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 435CA45DE53
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 13:47:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 14A5345DE4F
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 13:47:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 02FE61DB803F
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 13:47:45 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B19E41DB8037
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 13:47:44 +0900 (JST)
Message-ID: <4FE549E8.2050905@jp.fujitsu.com>
Date: Sat, 23 Jun 2012 13:45:28 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: RFC:  Easy-Reclaimable LRU list
References: <4FE012CD.6010605@kernel.org> <4FE37434.808@linaro.org> <4FE41752.8050305@kernel.org>
In-Reply-To: <4FE41752.8050305@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Anton Vorontsov <anton.vorontsov@linaro.org>, Pekka Enberg <penberg@kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Hugh Dickins <hughd@google.com>

(2012/06/22 15:57), Minchan Kim wrote:
> Hi John,
>
> On 06/22/2012 04:21 AM, John Stultz wrote:
>
>> On 06/18/2012 10:49 PM, Minchan Kim wrote:
>>> Hi everybody!
>>>
>>> Recently, there are some efforts to handle system memory pressure.
>>>
>>> 1) low memory notification - [1]
>>> 2) fallocate(VOLATILE) - [2]
>>> 3) fadvise(NOREUSE) - [3]
>>>
>>> For them, I would like to add new LRU list, aka "Ereclaimable" which
>>> is opposite of "unevictable".
>>> Reclaimable LRU list includes _easy_ reclaimable pages.
>>> For example, easy reclaimable pages are following as.
>>>
>>> 1. invalidated but remained LRU list.
>>> 2. pageout pages for reclaim(PG_reclaim pages)
>>> 3. fadvise(NOREUSE)
>>> 4. fallocate(VOLATILE)
>>>
>>> Their pages shouldn't stir normal LRU list and compaction might not
>>> migrate them, even.
>>> Reclaimer can reclaim Ereclaimable pages before normal lru list and
>>> will avoid unnecessary
>>> swapout in anon pages in easy-reclaimable LRU list.
>>
>> I was hoping there would be further comment on this by more core VM
>> devs, but so far things have been quiet (is everyone on vacation?).
>
>
> At least, there are no dissent comment until now.
> Let be a positive. :)

I think this is interesting approach. Major concern is how to guarantee EReclaimable
pages are really EReclaimable...Do you have any idea ? madviced pages are really
EReclaimable ?

A (very) small concern is will you use one more page-flags for this ? ;)

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
