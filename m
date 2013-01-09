Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 859CA6B0071
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 17:52:50 -0500 (EST)
Date: Wed, 09 Jan 2013 23:52:47 +0100
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
MIME-Version: 1.0
References: <50EDE41C.7090107@iskon.hr> <20130109134816.db51a820.akpm@linux-foundation.org>
In-Reply-To: <20130109134816.db51a820.akpm@linux-foundation.org>
Message-ID: <50EDF4BF.7000108@iskon.hr>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] mm: wait for congestion to clear on all zones
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 09.01.2013 22:48, Andrew Morton wrote:
> On Wed, 09 Jan 2013 22:41:48 +0100
> Zlatko Calusic <zlatko.calusic@iskon.hr> wrote:
>
>> Currently we take a short nap (HZ/10) and wait for congestion to clear
>> before taking another pass with lower priority in balance_pgdat(). But
>> we do that only for the highest zone that we encounter is unbalanced
>> and congested.
>>
>> This patch changes that to wait on all congested zones in a single
>> pass in the hope that it will save us some scanning that way. Also we
>> take a nap as soon as congested zone is encountered and sc.priority <
>> DEF_PRIORITY - 2 (aka kswapd in trouble).
>>
>> ...
>>
>> The patch is against the mm tree. Make sure that
>> mm-avoid-calling-pgdat_balanced-needlessly.patch is applied first (not
>> yet in the mmotm tree). Tested on half a dozen systems with different
>> workloads for the last few days, working really well!
>
> But what are the user-observable effcets of this change?  Less kernel
> CPU consumption, presumably?  Did you quantify it?
>

And I forgot to answer all the questions... :(

Actually, I did record kswapd CPU usage after 5 days of uptime and I 
intend to compare it with the new data (after few more days pass). I 
expect maybe slightly better results.

But, I think it's obvious from my first reply that my primary goal with 
this patch is correctness, not optimization. So, I won't be dissapointed 
a little bit if kswapd CPU usage stays the same, so long as the memory 
utilization remains this smooth. ;)

-- 
Zlatko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
