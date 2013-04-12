Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 447216B0002
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 17:14:43 -0400 (EDT)
Message-ID: <51687940.8090006@bitsync.net>
Date: Fri, 12 Apr 2013 23:14:40 +0200
From: Zlatko Calusic <zcalusic@bitsync.net>
MIME-Version: 1.0
Subject: Re: [PATCH 0/10] Reduce system disruption due to kswapd V2
References: <1365505625-9460-1-git-send-email-mgorman@suse.de> <51672331.6070605@bitsync.net> <20130412193947.GJ11656@suse.de> <5168699A.40407@bitsync.net> <20130412204129.GA13146@suse.de>
In-Reply-To: <20130412204129.GA13146@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12.04.2013 22:41, Mel Gorman wrote:
> On Fri, Apr 12, 2013 at 10:07:54PM +0200, Zlatko Calusic wrote:
>> On 12.04.2013 21:40, Mel Gorman wrote:
>>> On Thu, Apr 11, 2013 at 10:55:13PM +0200, Zlatko Calusic wrote:
>>>> On 09.04.2013 13:06, Mel Gorman wrote:
>>>> <SNIP>
>>>>
>>>> - The only slightly negative thing I observed is that with the patch
>>>> applied kswapd burns 10x - 20x more CPU. So instead of about 15
>>>> seconds, it has now spent more than 4 minutes on one particular
>>>> machine with a quite steady load (after about 12 days of uptime).
>>>> Admittedly, that's still nothing too alarming, but...
>>>>
>>>
>>> Would you happen to know what circumstances trigger the higher CPU
>>> usage?
>>>
>>
>> Really nothing special. The server is lightly loaded, but it does
>> enough reading from the disk so that pagecache is mostly populated
>> and page reclaiming is active. So, kswapd is no doubt using CPU time
>> gradually, nothing extraordinary.
>>
>> When I sent my reply yesterday, the server uptime was 12 days, and
>> kswapd had accumulated 4:28 CPU time. Now, approx 24 hours later (13
>> days uptime):
>>
>> root        23  0.0  0.0      0     0 ?        S    Mar30   4:52 [kswapd0]
>>
>
> Ok, that's not too crazy.
>

Certainly.

>> I will apply your v3 series soon and see if there's any improvement
>> wrt CPU usage, although as I said I don't see that as a big issue.
>> It's still only 0.013% of available CPU resources (dual core CPU).
>>
>
> Excellent, thanks very much for testing and reporting back.

The pleasure is all mine. I really admire your work.

> I read your
> mail on the zone balancing and FWIW I would not have expected this series
> to have any impact on it.

Good to know. At first I thought that your changes on the anon/file 
balance could make something different, obviously not.

> I do not have a good theory yet as to what the
> problem is but I'll give it some thought and se what I come up with. I'll
> be at LSF/MM next week so it might take me a while.
>

Yeah, that's definitely not something to be solved quickly, let it wait 
until you have more time, and I'll also continue to test various things 
after a slight break.

It's a quite subtle issue, although the solution will probably be simple 
and obvious. But, I also think it'll take a lot of time to find it. I 
tried to develop an artificial test case to speed up debugging, but 
failed horribly. It seems that the issue can be seen only on real workloads.

-- 
Zlatko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
