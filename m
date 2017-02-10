Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2E24D6B0389
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 08:11:53 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 67so12403901wrb.5
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 05:11:53 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r10si1177201wma.26.2017.02.10.05.11.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Feb 2017 05:11:52 -0800 (PST)
Subject: Re: [PATCH] vmscan: fix zone balance check in prepare_kswapd_sleep
References: <719282122.1183240.1486298780546.ref@mail.yahoo.com>
 <719282122.1183240.1486298780546@mail.yahoo.com>
 <20170206161715.sfz6lm3vmahlnxx6@techsingularity.net>
 <68644e18-ed8d-0559-4ac2-fb3162f6ba67@yahoo.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <901a8aba-b211-9a1a-f4a3-4ad70ae8918b@suse.cz>
Date: Fri, 10 Feb 2017 14:11:50 +0100
MIME-Version: 1.0
In-Reply-To: <68644e18-ed8d-0559-4ac2-fb3162f6ba67@yahoo.com>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shantanu Goel <sgoel01@yahoo.com>, Mel Gorman <mgorman@techsingularity.net>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

On 02/07/2017 01:16 AM, Shantanu Goel wrote:
> Hi,
>
> On 02/06/2017 11:17 AM, Mel Gorman wrote:
>
>> On Sun, Feb 05, 2017 at 12:46:20PM +0000, Shantanu Goel wrote:
>>> On 4.9.7 kswapd is failing to wake up kcompactd due to a mismatch in the zone balance check between balance_pgdat() and prepare_kswapd_sleep().  balance_pgdat() returns as soon as a single zone satisfies the allocation but prepare_kswapd_sleep() requires all zones to do the same.  This causes prepare_kswapd_sleep() to never succeed except in the order == 0 case and consequently, wakeup_kcompactd() is never called.  On my machine prior to apply this patch, the state of compaction from /proc/vmstat looked this way after a day and a half of uptime:
>>>
>>> compact_migrate_scanned 240496
>>> compact_free_scanned 76238632
>>> compact_isolated 123472
>>> compact_stall 1791
>>> compact_fail 29
>>> compact_success 1762
>>> compact_daemon_wake 0
>>>
>>>
>>> After applying the patch and about 10 hours of uptime the state looks like this:
>>>
>>> compact_migrate_scanned 59927299
>>> compact_free_scanned 2021075136
>>> compact_isolated 640926
>>> compact_stall 4
>>> compact_fail 2
>>> compact_success 2
>>> compact_daemon_wake 5160

I've just seen similar results in a test, so you can add:

Tested-by: Vlastimil Babka <vbabka@suse.cz>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
