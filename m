Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 13FEA6B027B
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 11:02:01 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id o3-v6so3293471oti.8
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 08:02:01 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f72-v6sor7015768otf.258.2018.04.17.08.01.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Apr 2018 08:01:57 -0700 (PDT)
Subject: Re: [LSF/MM TOPIC] CMA and larger page sizes
References: <3a3d724e-4d74-9bd8-60f3-f6896cffac7a@redhat.com>
 <20180417113656.GA16083@dhcp22.suse.cz>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <bc8e54d2-7224-0e8c-d7db-54fc4625eae8@redhat.com>
Date: Tue, 17 Apr 2018 08:01:53 -0700
MIME-Version: 1.0
In-Reply-To: <20180417113656.GA16083@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On 04/17/2018 04:36 AM, Michal Hocko wrote:
> On Fri 26-01-18 02:08:14, Laura Abbott wrote:
>> CMA as it's currently designed requires alignment to the pageblock size c.f.
>>
>>          /*
>>           * Sanitise input arguments.
>>           * Pages both ends in CMA area could be merged into adjacent unmovable
>>           * migratetype page by page allocator's buddy algorithm. In the case,
>>           * you couldn't get a contiguous memory, which is not what we want.
>>           */
>>          alignment = max(alignment,  (phys_addr_t)PAGE_SIZE <<
>>                            max_t(unsigned long, MAX_ORDER - 1, pageblock_order));
>>
>>
>> On arm64 with 64K page size and transparent huge page, this gives an alignment
>> of 512MB. This is quite restrictive and can eat up significant portions of
>> memory on smaller memory targets. Adjusting the configuration options really
>> isn't ideal for distributions that aim to have a single image which runs on
>> all targets.
>>
>> Approaches I've thought about:
>> - Making CMA alignment less restrictive (and dealing with the fallout from
>> the comment above)
>> - Command line option to force a reasonable alignment
> 
> Laura, are you still interested discussing this or other CMA related
> topic?
> 

In light of Joonsoo's patches, I don't think we need a lot of time
but I'd still like some chance to discuss. I think there was some
other interest in CMA topics so it can be combined with those if
they are happening as well.

Thanks,
Laura
