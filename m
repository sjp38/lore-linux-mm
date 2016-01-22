Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id 91520828DF
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 13:18:07 -0500 (EST)
Received: by mail-qk0-f170.google.com with SMTP id o6so31949108qkc.2
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 10:18:07 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n83si8268788qhn.6.2016.01.22.10.18.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jan 2016 10:18:06 -0800 (PST)
Subject: Re: [Lsf-pc] [LSF/MM ATTEND] 2016: Requests to attend MM-summit
References: <87k2n2usyf.fsf@linux.vnet.ibm.com>
 <20160122201707.1271a279@cotter.ozlabs.ibm.com>
 <20160122141948.GG16898@quack.suse.cz>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <56A2725B.1090509@redhat.com>
Date: Fri, 22 Jan 2016 10:18:03 -0800
MIME-Version: 1.0
In-Reply-To: <20160122141948.GG16898@quack.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, Balbir Singh <bsingharora@gmail.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org

On 01/22/2016 06:19 AM, Jan Kara wrote:
> On Fri 22-01-16 20:17:07, Balbir Singh wrote:
>> On Fri, 22 Jan 2016 10:11:12 +0530
>> "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
>>
>>> Hi,
>>>
>>> I would like to attend LSF/MM this year (2016).
>>>
>>> My main interest is in MM related topics although I am also interested
>>> in the btrfs status discussion (particularly related to subpage size block
>>> size topic), if we are having one. Most of my recent work in the kernel is
>>> related to adding ppc64 support for different MM features. My current focus
>>> is on adding Linux support for the new radix MMU model of Power9.
>>>
>>> Topics of interest include:
>>>
>>> * CMA allocator issues:
>>>    (1) order zero allocation failures:
>>>        We are observing order zero non-movable allocation failures in kernel
>>> with CMA configured. We don't start a reclaim because our free memory check
>>> does not consider free_cma. Hence the reclaim code assume we have enough free
>>> pages. Joonsoo Kim tried to fix this with his ZOME_CMA patches. I would
>>> like to discuss the challenges in getting this merged upstream.
>>> https://lkml.org/lkml/2015/2/12/95 (ZONE_CMA)
>>>
>>> Others needed for the discussion:
>>> Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>>
>>>    (2) CMA allocation failures due to pinned pages in the region:
>>>        We allow only movable allocation from the CMA region to enable us
>>> to migrate those pages later when we get a CMA allocation request. But
>>> if we pin those movable pages, we will fail the migration which can result
>>> in CMA allocation failure. One such report can be found here.
>>> http://article.gmane.org/gmane.linux.kernel.mm/136738
>>>
>>> Peter Zijlstra's VM_PINNED patch series should help in fixing the issue. I would
>>> like to discuss what needs to be done to get this patch series merged upstream
>>> https://lkml.org/lkml/2014/5/26/345 (VM_PINNED)
>>>
>>> Others needed for the discussion:
>>> Peter Zijlstra <peterz@infradead.org>
>>
>> +1
>>
>> I agree CMA design is a concern. I also noticed that today all CMA pages come
>> from one node. On a NUMA box you'll see cross traffic going to that region -
>> although from kernel only text. It should be discussed at the summit and Aneesh
>> would be a good representative
>
> I'm not really an mm guy but CMA has been discussed already last year, and
> I think even the year before... Are we moving somewhere? So if this is
> about hashing out what blocks VM_PINNED series (I think it may be just a
> lack of Peter's persistence in pushing it ;) then that looks like a
> sensible goal. Some other CMA architecture discussions need IMHO a more
> concrete proposals...
>
> 								Honza
>

The conclusion from the CMA session last year was that pinned pages need to be
fixed up at the caller sites doing the pinning. Each caller site really needs
to be taken individually. I think the discussion last year was good but if
it's going to end up with a different conclusion I agree there needs to be
concrete proposals.

Something that could be worth discussing as well is Joonsoo Kim's proposal for
page reference tracking http://thread.gmane.org/gmane.linux.kernel.api/16138

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
