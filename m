Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 826E06B0002
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 06:54:05 -0400 (EDT)
Message-ID: <514AE6CB.2040803@bitsync.net>
Date: Thu, 21 Mar 2013 11:54:03 +0100
From: Zlatko Calusic <zcalusic@bitsync.net>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/8] Reduce system disruption due to kswapd
References: <1363525456-10448-1-git-send-email-mgorman@suse.de> <20130321104440.GA5053@brouette>
In-Reply-To: <20130321104440.GA5053@brouette>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>

On 21.03.2013 11:44, Damien Wyart wrote:
> Hi,
>
>> Kswapd and page reclaim behaviour has been screwy in one way or the
>> other for a long time. [...]
>
>>   include/linux/mmzone.h |  16 ++
>>   mm/vmscan.c            | 387 +++++++++++++++++++++++++++++--------------------
>>   2 files changed, 245 insertions(+), 158 deletions(-)
>
> Do you plan to respin the series with all the modifications coming from
> the various answers applied? I've not found a git repo hosting the
> series and I would prefer testing the most recent version.
>

Same thing here, Mel. Thanks for the great work! I've been quite busy 
this week, but I promise to spend some time reviewing the patches this 
coming weekend. I would also appreciate if you could send the updated 
patches in the meantime. Or even better, point us towards the git tree 
where this treasure resides.

Regards,
-- 
Zlatko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
