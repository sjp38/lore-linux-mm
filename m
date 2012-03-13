Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id BD6526B004A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 10:57:13 -0400 (EDT)
Message-ID: <4F5F603F.2070600@redhat.com>
Date: Tue, 13 Mar 2012 10:57:03 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Control page reclaim granularity
References: <20120308073412.GA6975@gmail.com> <20120308093514.GA28856@barrios> <4F5E0E5C.8040508@redhat.com> <20120313025756.GC7125@barrios>
In-Reply-To: <20120313025756.GC7125@barrios>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, kosaki.motohiro@jp.fujitsu.com

On 03/12/2012 10:57 PM, Minchan Kim wrote:
> On Mon, Mar 12, 2012 at 10:55:24AM -0400, Rik van Riel wrote:
>> On 03/08/2012 04:35 AM, Minchan Kim wrote:

>>> Before we were trying to keep mapped pages in memory(See calc_reclaim_mapped).
>>> But we removed that routine when we applied split lru page replacement.
>>> Rik, KOSAKI. What's the rationale?
>>
>> One main reason is scalability.  We have to treat pages
>> in such a way that we do not have to search through
>> gigabytes of memory to find a few eviction candidates
>> to place on the inactive list - where they could get
>> reused and stopped from eviction again.
>
> Okay. Thanks, Rik.
> Then, another question.
> Why did we handle mmaped page specially at that time?
> Just out of curiosity.

We had to, because we had only one set of LRU lists.

Something had to be done to keep streaming IO from pushing
other things out of memory.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
