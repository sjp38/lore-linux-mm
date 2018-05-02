Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 94DF06B0005
	for <linux-mm@kvack.org>; Wed,  2 May 2018 09:38:43 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id k3so12921588pff.23
        for <linux-mm@kvack.org>; Wed, 02 May 2018 06:38:43 -0700 (PDT)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00073.outbound.protection.outlook.com. [40.107.0.73])
        by mx.google.com with ESMTPS id y23si11639997pff.177.2018.05.02.06.38.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 02 May 2018 06:38:42 -0700 (PDT)
Subject: Re: Page allocator bottleneck
References: <cef85936-10b2-5d76-9f97-cb03b418fd94@mellanox.com>
 <20170915102320.zqceocmvvkyybekj@techsingularity.net>
 <d8cfaf8b-7601-2712-f9f2-8327c720db5a@mellanox.com>
 <1c218381-067e-7757-ccc2-4e5befd2bfc3@mellanox.com>
 <20180421081505.GA24916@intel.com>
 <127df719-b978-60b7-5d77-3c8efbf2ecff@mellanox.com>
 <0dea4da6-8756-22d4-c586-267217a5fa63@mellanox.com>
 <20180423131033.GA13792@intel.com> <20180427084558.GB4009@intel.com>
From: Tariq Toukan <tariqt@mellanox.com>
Message-ID: <b59961b4-a587-64b6-7258-951470cf5686@mellanox.com>
Date: Wed, 2 May 2018 16:38:31 +0300
MIME-Version: 1.0
In-Reply-To: <20180427084558.GB4009@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>, Tariq Toukan <tariqt@mellanox.com>
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, David Miller <davem@davemloft.net>, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>, Alexei Starovoitov <ast@fb.com>, Saeed Mahameed <saeedm@mellanox.com>, Eran Ben Elisha <eranbe@mellanox.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>



On 27/04/2018 11:45 AM, Aaron Lu wrote:
> On Mon, Apr 23, 2018 at 09:10:33PM +0800, Aaron Lu wrote:
>> On Mon, Apr 23, 2018 at 11:54:57AM +0300, Tariq Toukan wrote:
>>> Hi,
>>>
>>> I ran my tests with your patches.
>>> Initial BW numbers are significantly higher than I documented back then in
>>> this mail-thread.
>>> For example, in driver #2 (see original mail thread), with 6 rings, I now
>>> get 92Gbps (slightly less than linerate) in comparison to 64Gbps back then.
>>>
>>> However, there were many kernel changes since then, I need to isolate your
>>> changes. I am not sure I can finish this today, but I will surely get to it
>>> next week after I'm back from vacation.
>>>
>>> Still, when I increase the scale (more rings, i.e. more cpus), I see that
>>> queued_spin_lock_slowpath gets to 60%+ cpu. Still high, but lower than it
>>> used to be.
>>
>> I wonder if it is on allocation path or free path?
> 
> Just FYI, I have pushed two more commits on top of the branch.
> They should improve free path zone lock contention for MIGRATE_UNMOVABLE
> pages(most kernel code alloc such pages), you may consider apply them if
> free path contention is a problem.
> 

Hi Aaron,
Thanks for the update, I did not analyze the contention yet.
I am back in office and will start testing soon.
