Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 386E76B0038
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 17:40:28 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v78so2063239pfk.8
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 14:40:28 -0700 (PDT)
Received: from out4441.biz.mail.alibaba.com (out4441.biz.mail.alibaba.com. [47.88.44.41])
        by mx.google.com with ESMTPS id bb11si3848291plb.330.2017.10.17.14.40.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Oct 2017 14:40:26 -0700 (PDT)
Subject: Re: [PATCH 3/3] mm: oom: show unreclaimable slab info when
 unreclaimable slabs > user memory
References: <1507656303-103845-1-git-send-email-yang.s@alibaba-inc.com>
 <1507656303-103845-4-git-send-email-yang.s@alibaba-inc.com>
 <alpine.DEB.2.10.1710161709460.140151@chino.kir.corp.google.com>
 <20171017074448.qupoajpjbcfdpz5z@dhcp22.suse.cz>
 <alpine.DEB.2.10.1710171357260.100885@chino.kir.corp.google.com>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <7ac4f9f6-3c3d-c1df-e60f-a519650cd330@alibaba-inc.com>
Date: Wed, 18 Oct 2017 05:40:06 +0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1710171357260.100885@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>
Cc: cl@linux.com, penberg@kernel.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 10/17/17 1:59 PM, David Rientjes wrote:
> On Tue, 17 Oct 2017, Michal Hocko wrote:
> 
>> On Mon 16-10-17 17:15:31, David Rientjes wrote:
>>> Please simply dump statistics for all slab caches where the memory
>>> footprint is greater than 5% of system memory.
>>
>> Unconditionally? User controlable?
> 
> Unconditionally, it's a single line of output per slab cache and there
> can't be that many of them if each is using >5% of memory.

Soi 1/4 ?you mean just dump the single slab cache if its size > 5% of system 
memory instead of all slab caches?

Thanks,
Yang

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
