Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id CC70E6B0253
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 19:13:17 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id d28so7322892pfe.1
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 16:13:17 -0700 (PDT)
Received: from out4441.biz.mail.alibaba.com (out4441.biz.mail.alibaba.com. [47.88.44.41])
        by mx.google.com with ESMTPS id ay2si453034plb.244.2017.10.19.16.13.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Oct 2017 16:13:16 -0700 (PDT)
Subject: Re: [PATCH 3/3] mm: oom: show unreclaimable slab info when
 unreclaimable slabs > user memory
References: <1507656303-103845-1-git-send-email-yang.s@alibaba-inc.com>
 <1507656303-103845-4-git-send-email-yang.s@alibaba-inc.com>
 <alpine.DEB.2.10.1710161709460.140151@chino.kir.corp.google.com>
 <20171017074448.qupoajpjbcfdpz5z@dhcp22.suse.cz>
 <alpine.DEB.2.10.1710171357260.100885@chino.kir.corp.google.com>
 <7ac4f9f6-3c3d-c1df-e60f-a519650cd330@alibaba-inc.com>
 <alpine.DEB.2.10.1710171449000.100885@chino.kir.corp.google.com>
 <a324af3f-f5c4-8c26-400e-ca3a590db37d@alibaba-inc.com>
 <alpine.DEB.2.10.1710171537170.141832@chino.kir.corp.google.com>
 <20171019072809.xykifzpsiabdjv6m@dhcp22.suse.cz>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <0353184c-7cad-7222-6fea-2c5df3dbe851@alibaba-inc.com>
Date: Fri, 20 Oct 2017 07:12:56 +0800
MIME-Version: 1.0
In-Reply-To: <20171019072809.xykifzpsiabdjv6m@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>
Cc: cl@linux.com, penberg@kernel.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 10/19/17 12:28 AM, Michal Hocko wrote:
> On Tue 17-10-17 15:39:08, David Rientjes wrote:
>> On Wed, 18 Oct 2017, Yang Shi wrote:
>>
>>>> Yes, this should catch occurrences of "huge unreclaimable slabs", right?
>>>
>>> Yes, it sounds so. Although single "huge" unreclaimable slab might not result
>>> in excessive slabs use in a whole, but this would help to filter out "small"
>>> unreclaimable slab.
>>>
>>
>> Keep in mind this is regardless of SLAB_RECLAIM_ACCOUNT: your patch has
>> value beyond only unreclaimable slab, it can also be used to show
>> instances where the oom killer was invoked without properly reclaiming
>> slab.  If the total footprint of a slab cache exceeds 5%, I think a line
>> should be emitted unconditionally to the kernel log.
> 
> agreed. I am not sure 5% is the greatest fit but we can tune that later.

5% might be too few. For example, on a machine with 200G memory, if 
there is 80G page cache, radix_tree_node might consume 10G. IMHO, 10% 
might be better.

Yang

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
