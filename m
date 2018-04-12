Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4AFB66B0003
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 21:07:06 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id z2-v6so2465928plk.3
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 18:07:06 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s1sor657652pfj.81.2018.04.11.18.07.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Apr 2018 18:07:05 -0700 (PDT)
Subject: Re: [LSF/MM TOPIC] CMA and larger page sizes
References: <3a3d724e-4d74-9bd8-60f3-f6896cffac7a@redhat.com>
 <20180126172527.GI5027@dhcp22.suse.cz> <20180404051115.GC6628@js1304-desktop>
 <075843db-ec6e-3822-a60c-ae7487981f09@redhat.com>
 <d88676d9-8f42-2519-56bf-776e46b1180e@suse.cz>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <b1420dd8-23ae-89e8-3b9d-62663bd69e24@redhat.com>
Date: Wed, 11 Apr 2018 18:06:59 -0700
MIME-Version: 1.0
In-Reply-To: <d88676d9-8f42-2519-56bf-776e46b1180e@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On 04/11/2018 01:02 PM, Vlastimil Babka wrote:
> On 04/11/2018 09:55 PM, Laura Abbott wrote:
>> On 04/03/2018 10:11 PM, Joonsoo Kim wrote:
>>> If the patchset 'manage the memory of the CMA area by using the ZONE_MOVABLE' is
>>> merged, this restriction can be removed since there is no unmovable
>>> pageblock in ZONE_MOVABLE. Just quick thought. :)
>>>
>>> Thanks.
>>>
>>
>> Thanks for that pointer. What's the current status of that patchset? Was that
>> one that needed more review/testing?
> 
> It was merged by Linus today, see around commit bad8c6c0b114 ("mm/cma:
> manage the memory of the CMA area by using the ZONE_MOVABLE")
> 
> Congrats, Joonsoo :)
> 

I took a look at this a little bit more and while it's true we don't
have the unmovable restriction anymore, CMA is still tied to the pageblock
size (512MB) because we still have MIGRATE_CMA. I guess making the
pageblock smaller seems like the most plausible approach?

Thanks,
Laura
