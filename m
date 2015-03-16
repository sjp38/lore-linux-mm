Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2879A6B0032
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 07:43:58 -0400 (EDT)
Received: by qcaz10 with SMTP id z10so40472609qca.1
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 04:43:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w33si9631630qgw.43.2015.03.16.04.43.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Mar 2015 04:43:57 -0700 (PDT)
Message-ID: <5506C1F6.1090803@redhat.com>
Date: Mon, 16 Mar 2015 07:43:50 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: kswapd hogging in lowmem_shrink
References: <CAB5gotvwyD74UugjB6XQ_v=o11Hu9wAuA6N94UvGObPARYEz0w@mail.gmail.com>	<5502F9BC.2020001@redhat.com> <CAB5gotsXCiHiwnwg0vMOi1qS8FoUtUJfsaTSe0acYFYgoOUh=Q@mail.gmail.com>
In-Reply-To: <CAB5gotsXCiHiwnwg0vMOi1qS8FoUtUJfsaTSe0acYFYgoOUh=Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vaibhav Shinde <v.bhav.shinde@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>

On 03/16/2015 03:45 AM, Vaibhav Shinde wrote:
> 
> 
> On Fri, Mar 13, 2015 at 7:52 AM, Rik van Riel <riel@redhat.com
> <mailto:riel@redhat.com>> wrote:
>>
>> On 03/13/2015 10:25 AM, Vaibhav Shinde wrote:
>> >
>> > On low memory situation, I see various shrinkers being invoked, but in
>> > lowmem_shrink() case, kswapd is found to be hogging for around 150msecs.
>> >
>> > Due to this my application suffer latency issue, as the cpu was not
>> > released by kswapd0.
>> >
>> > I took below traces with vmscan events, that show lowmem_shrink taking
>> > such long time for execution.
>>
>> This is the Android low memory killer, which kills the
>> task with the lowest priority in the system.
>>
>> The low memory killer will iterate over all the tasks
>> in the system to identify the task to kill.
>>
>> This is not a problem in Android systems, and other
>> small systems where this piece of code is used.
>>
>> What kind of system are you trying to use the low
>> memory killer on?
>>
>> How many tasks are you running?
>>
> yes, lowmemorykiller kills the task depending on its oom_score, I am
> using a embedded device with 2GB memory, there are task running that
> cause lowmemory situation - no issue about it.
> 
> But my concern is kswapd takes too long to iterate through all the
> processes(lowmem_shrink() => for_each_process()), the time taken is
> around 150msec, due to which my high priority application suffer system
> latency that cause malfunctioning.

If it is an issue for you, you will have to fix that.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
