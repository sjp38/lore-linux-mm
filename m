Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id A3E0A6B0003
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 15:55:07 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id o2-v6so1823699plk.14
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 12:55:07 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t186sor455241pgc.135.2018.04.11.12.55.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Apr 2018 12:55:06 -0700 (PDT)
Subject: Re: [LSF/MM TOPIC] CMA and larger page sizes
References: <3a3d724e-4d74-9bd8-60f3-f6896cffac7a@redhat.com>
 <20180126172527.GI5027@dhcp22.suse.cz> <20180404051115.GC6628@js1304-desktop>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <075843db-ec6e-3822-a60c-ae7487981f09@redhat.com>
Date: Wed, 11 Apr 2018 12:55:00 -0700
MIME-Version: 1.0
In-Reply-To: <20180404051115.GC6628@js1304-desktop>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On 04/03/2018 10:11 PM, Joonsoo Kim wrote:
> Hello, Laura.
> Sorry for a late response.
> 
> 
> On Fri, Jan 26, 2018 at 06:25:27PM +0100, Michal Hocko wrote:
>> [Ccing Joonsoo]
> 
> Thanks! Michal.
> 
>>
>> On Fri 26-01-18 02:08:14, Laura Abbott wrote:
>>> CMA as it's currently designed requires alignment to the pageblock size c.f.
>>>
>>>          /*
>>>           * Sanitise input arguments.
>>>           * Pages both ends in CMA area could be merged into adjacent unmovable
>>>           * migratetype page by page allocator's buddy algorithm. In the case,
>>>           * you couldn't get a contiguous memory, which is not what we want.
>>>           */
>>>          alignment = max(alignment,  (phys_addr_t)PAGE_SIZE <<
>>>                            max_t(unsigned long, MAX_ORDER - 1, pageblock_order));
>>>
>>>
>>> On arm64 with 64K page size and transparent huge page, this gives an alignment
>>> of 512MB. This is quite restrictive and can eat up significant portions of
>>> memory on smaller memory targets. Adjusting the configuration options really
>>> isn't ideal for distributions that aim to have a single image which runs on
>>> all targets.
>>>
>>> Approaches I've thought about:
>>> - Making CMA alignment less restrictive (and dealing with the fallout from
>>> the comment above)
>>> - Command line option to force a reasonable alignment
> 
> If the patchset 'manage the memory of the CMA area by using the ZONE_MOVABLE' is
> merged, this restriction can be removed since there is no unmovable
> pageblock in ZONE_MOVABLE. Just quick thought. :)
> 
> Thanks.
> 

Thanks for that pointer. What's the current status of that patchset? Was that
one that needed more review/testing?

Thanks,
Laura
