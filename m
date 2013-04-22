Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 9F59E6B0032
	for <linux-mm@kvack.org>; Mon, 22 Apr 2013 02:43:48 -0400 (EDT)
Received: by mail-ie0-f173.google.com with SMTP id k5so6663035iea.4
        for <linux-mm@kvack.org>; Sun, 21 Apr 2013 23:43:47 -0700 (PDT)
Message-ID: <5174DC17.6000809@gmail.com>
Date: Mon, 22 Apr 2013 14:43:35 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/10] Reduce system disruption due to kswapd V2
References: <1365505625-9460-1-git-send-email-mgorman@suse.de> <51672331.6070605@bitsync.net> <20130412193947.GJ11656@suse.de> <5168699A.40407@bitsync.net> <5174DA8F.2020400@bitsync.net>
In-Reply-To: <5174DA8F.2020400@bitsync.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zlatko Calusic <zcalusic@bitsync.net>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi Zlatko,
On 04/22/2013 02:37 PM, Zlatko Calusic wrote:
> On 12.04.2013 22:07, Zlatko Calusic wrote:
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
>> Really nothing special. The server is lightly loaded, but it does enough
>> reading from the disk so that pagecache is mostly populated and page
>> reclaiming is active. So, kswapd is no doubt using CPU time gradually,
>> nothing extraordinary.
>>
>> When I sent my reply yesterday, the server uptime was 12 days, and
>> kswapd had accumulated 4:28 CPU time. Now, approx 24 hours later (13
>> days uptime):
>>
>> root        23  0.0  0.0      0     0 ?        S    Mar30   4:52 
>> [kswapd0]
>>
>> I will apply your v3 series soon and see if there's any improvement wrt
>> CPU usage, although as I said I don't see that as a big issue. It's
>> still only 0.013% of available CPU resources (dual core CPU).
>>
>
> JFTR, v3 kswapd uses about 15% more CPU time than v2. 2:50 kswapd CPU 
> time after 6 days 14h uptime.
>
> And find attached another debugging graph that shows how ANON pages 
> are privileged in the ZONE_NORMAL on a 4GB machine. Take notice that 
> the number of pages in the ZONE_DMA32 is scaled (/5) to fit the graph 
> nicely.
>

Could you tell me how you draw this picture?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
