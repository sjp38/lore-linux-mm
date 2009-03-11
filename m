Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 658416B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 07:51:35 -0400 (EDT)
Received: by fxm26 with SMTP id 26so468462fxm.38
        for <linux-mm@kvack.org>; Wed, 11 Mar 2009 04:51:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090311114353.GA759@localhost>
References: <e2dc2c680903110341g6c9644b8j87ce3b364807e37f@mail.gmail.com>
	 <20090311114353.GA759@localhost>
Date: Wed, 11 Mar 2009 12:51:32 +0100
Message-ID: <e2dc2c680903110451m3cfa35d9s7a9fd942bcee39eb@mail.gmail.com>
Subject: Re: Memory usage per memory zone
From: jack marrow <jackmarrow2@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

2009/3/11 Wu Fengguang <fengguang.wu@intel.com>:
> Hi jack,
>
> On Wed, Mar 11, 2009 at 11:41:43AM +0100, jack marrow wrote:
>> Hello,
>>
>> I have a box where the oom-killer is killing processes due to running
>> out of memory in zone_normal. I can see using slabtop that the inode
>
> How do you know that the memory pressure on zone normal stand out alone?

For the normal zone only, I see "all_unreclaimable: yes" and 3 megs of free ram:

kernel: Normal free:2576kB min:3728kB low:7456kB high:11184kB
active:1304kB inactive:128kB present:901120kB pages_scanned:168951
all_unreclaimable? yes

>> caches are using up lots of memory and guess this is the problem, so
>> have cleared them using an echo to drop_caches.
>
> It would better be backed by concrete numbers...
>
>>
>> I would quite like to not guess though - is it possible to use slabtop
>> (or any other way) to view ram usage per zone so I can pick out the
>> culprit?
>
> /proc/zoneinfo and /proc/vmstat do have some per-zone numbers.
> Some of them deal with slabs.

Thanks, I'll read up on how to interpret these.

Do you recommend these two files for tracking down memory usage per
process per zone?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
