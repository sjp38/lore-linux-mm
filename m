Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 939676B0003
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 16:04:56 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id az8-v6so1866650plb.2
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 13:04:56 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n59-v6si1789074plb.46.2018.04.11.13.04.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Apr 2018 13:04:55 -0700 (PDT)
Subject: Re: [LSF/MM TOPIC] CMA and larger page sizes
References: <3a3d724e-4d74-9bd8-60f3-f6896cffac7a@redhat.com>
 <20180126172527.GI5027@dhcp22.suse.cz> <20180404051115.GC6628@js1304-desktop>
 <075843db-ec6e-3822-a60c-ae7487981f09@redhat.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d88676d9-8f42-2519-56bf-776e46b1180e@suse.cz>
Date: Wed, 11 Apr 2018 22:02:57 +0200
MIME-Version: 1.0
In-Reply-To: <075843db-ec6e-3822-a60c-ae7487981f09@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On 04/11/2018 09:55 PM, Laura Abbott wrote:
> On 04/03/2018 10:11 PM, Joonsoo Kim wrote:
>> If the patchset 'manage the memory of the CMA area by using the ZONE_MOVABLE' is
>> merged, this restriction can be removed since there is no unmovable
>> pageblock in ZONE_MOVABLE. Just quick thought. :)
>>
>> Thanks.
>>
> 
> Thanks for that pointer. What's the current status of that patchset? Was that
> one that needed more review/testing?

It was merged by Linus today, see around commit bad8c6c0b114 ("mm/cma:
manage the memory of the CMA area by using the ZONE_MOVABLE")

Congrats, Joonsoo :)

> Thanks,
> Laura
> 
