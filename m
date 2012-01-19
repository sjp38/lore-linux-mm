Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 3DD196B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 09:43:37 -0500 (EST)
Message-ID: <4F182BF3.7050809@redhat.com>
Date: Thu, 19 Jan 2012 09:42:59 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC 2/3] vmscan hook
References: <1326788038-29141-1-git-send-email-minchan@kernel.org> <1326788038-29141-3-git-send-email-minchan@kernel.org> <20120117173932.1c058ba4.kamezawa.hiroyu@jp.fujitsu.com> <20120117091356.GA29736@barrios-desktop.redhat.com> <20120117190512.047d3a03.kamezawa.hiroyu@jp.fujitsu.com> <20120117230801.GA903@barrios-desktop.redhat.com> <20120118091824.0bde46f7.kamezawa.hiroyu@jp.fujitsu.com> <4F16D46D.5080000@redhat.com> <20120119112528.eda78467.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120119112528.eda78467.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, leonid.moiseichuk@nokia.com, penberg@kernel.org, mel@csn.ul.ie, rientjes@google.com, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Marcelo Tosatti <mtosatti@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ronen Hod <rhod@redhat.com>

On 01/18/2012 09:25 PM, KAMEZAWA Hiroyuki wrote:
> On Wed, 18 Jan 2012 09:17:17 -0500
> Rik van Riel<riel@redhat.com>  wrote:
>
>> On 01/17/2012 07:18 PM, KAMEZAWA Hiroyuki wrote:
>>> On Wed, 18 Jan 2012 08:08:01 +0900
>>> Minchan Kim<minchan@kernel.org>   wrote:
>>>
>>>>>>> 2. can't we measure page-in/page-out distance by recording something ?
>>>>>>
>>>>>> I can't understand your point. What's relation does it with swapout prevent?
>>>>>>
>>>>>
>>>>> If distance between pageout ->   pagein is short, it means thrashing.
>>>>> For example, recoding the timestamp when the page(mapping, index) was
>>>>> paged-out, and check it at page-in.
>>>>
>>>> Our goal is prevent swapout. When we found thrashing, it's too late.
>>>
>>> If you want to prevent swap-out, don't swapon any. That's all.
>>> Then, you can check the number of FILE_CACHE and have threshold.
>>
>> I think you are getting hung up on a word here.
>>
>> As I understand it, the goal is to push out the point where
>> we start doing heavier swap IO, allowing us to overcommit
>> memory more heavily before things start really slowing down.
>>
>
> Yes.
>
> Hmm, considering that the issue is slow down,
>
> time values as
>
> - 'cpu time used for memory reclaim'
> - 'latency of page allocation'
> - 'application execution speed' ?
>
> may be a better score to see rather than just seeing lru's stat.

I believe those all qualify as "too late".

We want to prevent things from becoming bad, for as long
as we (easily) can.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
