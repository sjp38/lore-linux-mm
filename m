Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id C6F406B0152
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 20:12:30 -0400 (EDT)
Message-ID: <4FE8FE70.6050107@kernel.org>
Date: Tue, 26 Jun 2012 09:12:32 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: RFC:  Easy-Reclaimable LRU list
References: <4FE012CD.6010605@kernel.org> <4FE82555.2010704@parallels.com>
In-Reply-To: <4FE82555.2010704@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Anton Vorontsov <anton.vorontsov@linaro.org>, John Stultz <john.stultz@linaro.org>, Pekka Enberg <penberg@kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Hugh Dickins <hughd@google.com>

On 06/25/2012 05:46 PM, Glauber Costa wrote:

> On 06/19/2012 09:49 AM, Minchan Kim wrote:
>> Hi everybody!
>>
>> Recently, there are some efforts to handle system memory pressure.
>>
>> 1) low memory notification - [1]
>> 2) fallocate(VOLATILE) - [2]
>> 3) fadvise(NOREUSE) - [3]
>>
>> For them, I would like to add new LRU list, aka "Ereclaimable" which
>> is opposite of "unevictable".
>> Reclaimable LRU list includes_easy_  reclaimable pages.
>> For example, easy reclaimable pages are following as.
>>
>> 1. invalidated but remained LRU list.
>> 2. pageout pages for reclaim(PG_reclaim pages)
>> 3. fadvise(NOREUSE)
>> 4. fallocate(VOLATILE)
>>
>> Their pages shouldn't stir normal LRU list and compaction might not
>> migrate them, even.
> What about other things moving memory like CMA ?


Sorry for not being able to understand your point.
Can you elaborate a bit more?

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
