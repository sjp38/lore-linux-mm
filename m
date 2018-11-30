Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id ED6C96B5604
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 22:14:12 -0500 (EST)
Received: by mail-yb1-f199.google.com with SMTP id w13-v6so2698051ybm.11
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 19:14:12 -0800 (PST)
Received: from p3plsmtpa11-05.prod.phx3.secureserver.net (p3plsmtpa11-05.prod.phx3.secureserver.net. [68.178.252.106])
        by mx.google.com with ESMTPS id h124-v6si2295474yba.312.2018.11.29.19.14.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Nov 2018 19:14:11 -0800 (PST)
Subject: Re: [PATCH v2 0/6] RFC: gup+dma: tracking dma-pinned pages
References: <20181110085041.10071-1-jhubbard@nvidia.com>
 <942cb823-9b18-69e7-84aa-557a68f9d7e9@talpey.com>
 <97934904-2754-77e0-5fcb-83f2311362ee@nvidia.com>
 <5159e02f-17f8-df8b-600c-1b09356e46a9@talpey.com>
 <c1ba07d6-ebfa-ddb9-c25e-e5c1bfbecf74@nvidia.com>
 <15e4a0c0-cadd-e549-962f-8d9aa9fc033a@talpey.com>
 <313bf82d-cdeb-8c75-3772-7a124ecdfbd5@nvidia.com>
 <2aa422df-d5df-5ddb-a2e4-c5e5283653b5@talpey.com>
 <7a68b7fc-ff9d-381e-2444-909c9c2f6679@nvidia.com>
 <1939f47a-eaec-3f2c-4ae7-f92d9fba7693@talpey.com>
 <0f093af1-dee9-51b6-0795-2c073a951fed@nvidia.com>
 <c64387d6-c51d-185a-d2a4-1fedcdac0abe@talpey.com>
 <04c18816-e15d-bffd-e8be-eceefae77197@nvidia.com>
From: Tom Talpey <tom@talpey.com>
Message-ID: <79d1ee27-9ea0-3d15-3fc4-97c1bd79c990@talpey.com>
Date: Thu, 29 Nov 2018 22:14:11 -0500
MIME-Version: 1.0
In-Reply-To: <04c18816-e15d-bffd-e8be-eceefae77197@nvidia.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>, john.hubbard@gmail.com, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On 11/29/2018 10:00 PM, John Hubbard wrote:
> On 11/29/18 6:30 PM, Tom Talpey wrote:
>> On 11/29/2018 9:21 PM, John Hubbard wrote:
>>> On 11/29/18 6:18 PM, Tom Talpey wrote:
>>>> On 11/29/2018 8:39 PM, John Hubbard wrote:
>>>>> On 11/28/18 5:59 AM, Tom Talpey wrote:
>>>>>> On 11/27/2018 9:52 PM, John Hubbard wrote:
>>>>>>> On 11/27/18 5:21 PM, Tom Talpey wrote:
>>>>>>>> On 11/21/2018 5:06 PM, John Hubbard wrote:
>>>>>>>>> On 11/21/18 8:49 AM, Tom Talpey wrote:
>>>>>>>>>> On 11/21/2018 1:09 AM, John Hubbard wrote:
>>>>>>>>>>> On 11/19/18 10:57 AM, Tom Talpey wrote:
>>>>>>> [...]
>>>> Excerpting from below:
>>>>
>>>>> Baseline 4.20.0-rc3 (commit f2ce1065e767), as before:
>>>>>        read: IOPS=193k, BW=753MiB/s (790MB/s)(1024MiB/1360msec)
>>>>>       cpu          : usr=16.26%, sys=48.05%, ctx=251258, majf=0, minf=73
>>>>
>>>> vs
>>>>
>>>>> With patches applied:
>>>>>        read: IOPS=193k, BW=753MiB/s (790MB/s)(1024MiB/1360msec)
>>>>>       cpu          : usr=16.26%, sys=48.05%, ctx=251258, majf=0, minf=73
>>>>
>>>> Perfect results, not CPU limited, and full IOPS.
>>>>
>>>> Curiously identical, so I trust you've checked that you measured
>>>> both targets, but if so, I say it's good.
>>>>
>>>
>>> Argh, copy-paste error in the email. The real "before" is ever so slightly
>>> better, at 194K IOPS and 759 MB/s:
>>
>> Definitely better - note the system CPU is lower, which is probably the
>> reason for the increased IOPS.
>>
>>>      cpu          : usr=18.24%, sys=44.77%, ctx=251527, majf=0, minf=73
>>
>> Good result - a correct implementation, and faster.
>>
> 
> Thanks, Tom, I really appreciate your experience and help on what performance
> should look like here. (I'm sure you can guess that this is the first time
> I've worked with fio, heh.)

No problem, happy to chip in. Feel free to add my

Tested-By: Tom Talpey <ttalpey@microsoft.com>

I know, that's not the personal email I'm posting from, but it's me.

I'll be hopefully trying the code with the Linux SMB client (cifs.ko)
next week, Long Li is implementing direct io in that and we'll see how
it helps.

Mainly, I'm looking forward to seeing this enable RDMA-to-DAX.

Tom.

> 
> I'll send out a new, non-RFC patchset soon, then.
> 
> thanks,
> 
