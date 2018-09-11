Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6B51A8E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 11:00:52 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id n3-v6so4931284ljc.17
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 08:00:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h77-v6sor6681071lfh.36.2018.09.11.08.00.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Sep 2018 08:00:50 -0700 (PDT)
Date: Tue, 11 Sep 2018 15:00:48 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 1/3] mm/sparse: add likely to mem_section[root] check in
 sparse_index_init()
Message-ID: <20180911150048.5q6zmpz5m5cx3syu@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20180823130732.9489-1-richard.weiyang@gmail.com>
 <20180823130732.9489-2-richard.weiyang@gmail.com>
 <cc817bc8-bced-fb07-cb2d-c122463380a7@intel.com>
 <20180824150717.GA10093@WeideMacBook-Pro.local>
 <20180903222732.v52zdya2c2hkff7n@master>
 <20180909013807.6ux4cidt3nehofz5@master>
 <5140697b-540a-1db1-e300-af1aaece97ad@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5140697b-540a-1db1-e300-af1aaece97ad@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com

On Mon, Sep 10, 2018 at 01:30:11PM -0700, Dave Hansen wrote:
>On 09/08/2018 06:38 PM, owner-linux-mm@kvack.org wrote:
>> 
>> At last, here is the test result on my 4G virtual machine. I added printk
>> before and after sparse_memory_present_with_active_regions() and tested three
>> times with/without "likely".
>> 
>>                without      with
>>     Elapsed   0.000252     0.000250   -0.8%
>> 
>> The benefit seems to be too small on a 4G virtual machine or even this is not
>> stable. Not sure we can see some visible effect on a 32G machine.
>
>I think it's highly unlikely you have found something significant here.
>It's one system, in a VM and it's not being measured using a mechanism
>that is suitable for benchmarking (the kernel dmesg timestamps).
>
>Plus, if this is a really tight loop, the cpu's branch predictors will
>be good at it.

Hi, Dave

Thanks for your reply.

I think you are right. This part is not significant and cpu may do its
job well.

Hmm... I am still willing to hear your opinion on my analysis of this
situation. In which case we would use likely/unlikely.

For example, in this case the possibility is (255/ 256) if the system
has 32G RAM. Do we have a threshold of the possibility to use
likely/unlikely. Or we'd prefer not to use this any more? Let compiler
and cpu do their job.

Look forward your insights.

-- 
Wei Yang
Help you, Help me
