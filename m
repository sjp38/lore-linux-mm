Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 55B4B6B0038
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 18:20:29 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id b192so2471125pga.14
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 15:20:29 -0700 (PDT)
Received: from out4433.biz.mail.alibaba.com (out4433.biz.mail.alibaba.com. [47.88.44.33])
        by mx.google.com with ESMTPS id r26si6403583pfd.2.2017.10.17.15.20.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Oct 2017 15:20:28 -0700 (PDT)
Subject: Re: [PATCH 3/3] mm: oom: show unreclaimable slab info when
 unreclaimable slabs > user memory
References: <1507656303-103845-1-git-send-email-yang.s@alibaba-inc.com>
 <1507656303-103845-4-git-send-email-yang.s@alibaba-inc.com>
 <alpine.DEB.2.10.1710161709460.140151@chino.kir.corp.google.com>
 <20171017074448.qupoajpjbcfdpz5z@dhcp22.suse.cz>
 <alpine.DEB.2.10.1710171357260.100885@chino.kir.corp.google.com>
 <7ac4f9f6-3c3d-c1df-e60f-a519650cd330@alibaba-inc.com>
 <alpine.DEB.2.10.1710171449000.100885@chino.kir.corp.google.com>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <a324af3f-f5c4-8c26-400e-ca3a590db37d@alibaba-inc.com>
Date: Wed, 18 Oct 2017 06:20:09 +0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1710171449000.100885@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, cl@linux.com, penberg@kernel.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 10/17/17 2:50 PM, David Rientjes wrote:
> On Wed, 18 Oct 2017, Yang Shi wrote:
> 
>>>>> Please simply dump statistics for all slab caches where the memory
>>>>> footprint is greater than 5% of system memory.
>>>>
>>>> Unconditionally? User controlable?
>>>
>>> Unconditionally, it's a single line of output per slab cache and there
>>> can't be that many of them if each is using >5% of memory.
>>
>> Soi 1/4 ?you mean just dump the single slab cache if its size > 5% of system memory
>> instead of all slab caches?
>>
> 
> Yes, this should catch occurrences of "huge unreclaimable slabs", right?

Yes, it sounds so. Although single "huge" unreclaimable slab might not 
result in excessive slabs use in a whole, but this would help to filter 
out "small" unreclaimable slab.

Yang

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
