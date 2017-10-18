Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id EA5726B0038
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 15:10:01 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a8so4038151pfc.6
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 12:10:01 -0700 (PDT)
Received: from out4434.biz.mail.alibaba.com (out4434.biz.mail.alibaba.com. [47.88.44.34])
        by mx.google.com with ESMTPS id f81si1311085pfj.30.2017.10.18.12.09.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Oct 2017 12:10:00 -0700 (PDT)
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
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <3063d036-93b6-7ac9-30f6-fab493e5e5d4@alibaba-inc.com>
Date: Thu, 19 Oct 2017 03:09:40 +0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1710171537170.141832@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, cl@linux.com, penberg@kernel.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 10/17/17 3:39 PM, David Rientjes wrote:
> On Wed, 18 Oct 2017, Yang Shi wrote:
> 
>>> Yes, this should catch occurrences of "huge unreclaimable slabs", right?
>>
>> Yes, it sounds so. Although single "huge" unreclaimable slab might not result
>> in excessive slabs use in a whole, but this would help to filter out "small"
>> unreclaimable slab.
>>
> 
> Keep in mind this is regardless of SLAB_RECLAIM_ACCOUNT: your patch has
> value beyond only unreclaimable slab, it can also be used to show
> instances where the oom killer was invoked without properly reclaiming
> slab.  If the total footprint of a slab cache exceeds 5%, I think a line
> should be emitted unconditionally to the kernel log.

OK, sounds good. I will propose an incremental patch to see the comments.

Thanks,
Yang

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
