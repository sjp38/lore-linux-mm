Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 58FD76B0253
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 04:34:12 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id cy9so20545770pac.0
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 01:34:12 -0800 (PST)
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com. [202.81.31.145])
        by mx.google.com with ESMTPS id xe7si15806842pab.3.2016.01.28.01.34.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 28 Jan 2016 01:34:11 -0800 (PST)
Received: from localhost
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 28 Jan 2016 19:34:06 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 9C3C62CE8054
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 20:34:00 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u0S9Xg8b42663938
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 20:33:50 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u0S9XS4x026319
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 20:33:28 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [Lsf-pc] [LSF/MM ATTEND] 2016: Requests to attend MM-summit
In-Reply-To: <56A2725B.1090509@redhat.com>
References: <87k2n2usyf.fsf@linux.vnet.ibm.com> <20160122201707.1271a279@cotter.ozlabs.ibm.com> <20160122141948.GG16898@quack.suse.cz> <56A2725B.1090509@redhat.com>
Date: Thu, 28 Jan 2016 15:03:01 +0530
Message-ID: <87fuxi59rm.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>, Jan Kara <jack@suse.cz>, Balbir Singh <bsingharora@gmail.com>
Cc: linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org

Laura Abbott <labbott@redhat.com> writes:

> On 01/22/2016 06:19 AM, Jan Kara wrote:
>> On Fri 22-01-16 20:17:07, Balbir Singh wrote:
>>> On Fri, 22 Jan 2016 10:11:12 +0530
>>> "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
>>>
>>>> Hi,
>>>>
>>>> I would like to attend LSF/MM this year (2016).
>>>>
>>>> My main interest is in MM related topics although I am also interested
>>>> in the btrfs status discussion (particularly related to subpage size block
>>>> size topic), if we are having one. Most of my recent work in the kernel is
>>>> related to adding ppc64 support for different MM features. My current focus
>>>> is on adding Linux support for the new radix MMU model of Power9.
>>>>
>>>> Topics of interest include:
>>>>
>>>> * CMA allocator issues:
>>>>    (1) order zero allocation failures:
>>>>        We are observing order zero non-movable allocation failures in kernel
>>>> with CMA configured. We don't start a reclaim because our free memory check
>>>> does not consider free_cma. Hence the reclaim code assume we have enough free
>>>> pages. Joonsoo Kim tried to fix this with his ZOME_CMA patches. I would
>>>> like to discuss the challenges in getting this merged upstream.
>>>> https://lkml.org/lkml/2015/2/12/95 (ZONE_CMA)
>>>>
>>>> Others needed for the discussion:
>>>> Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>>>
>>>>    (2) CMA allocation failures due to pinned pages in the region:
>>>>        We allow only movable allocation from the CMA region to enable us
>>>> to migrate those pages later when we get a CMA allocation request. But
>>>> if we pin those movable pages, we will fail the migration which can result
>>>> in CMA allocation failure. One such report can be found here.
>>>> http://article.gmane.org/gmane.linux.kernel.mm/136738
>>>>
>>>> Peter Zijlstra's VM_PINNED patch series should help in fixing the issue. I would
>>>> like to discuss what needs to be done to get this patch series merged upstream
>>>> https://lkml.org/lkml/2014/5/26/345 (VM_PINNED)
>>>>
>>>> Others needed for the discussion:
>>>> Peter Zijlstra <peterz@infradead.org>
>>>
>>> +1
>>>
>>> I agree CMA design is a concern. I also noticed that today all CMA pages come
>>> from one node. On a NUMA box you'll see cross traffic going to that region -
>>> although from kernel only text. It should be discussed at the summit and Aneesh
>>> would be a good representative
>>
>> I'm not really an mm guy but CMA has been discussed already last year, and
>> I think even the year before... Are we moving somewhere? So if this is
>> about hashing out what blocks VM_PINNED series (I think it may be just a
>> lack of Peter's persistence in pushing it ;) then that looks like a
>> sensible goal. Some other CMA architecture discussions need IMHO a more
>> concrete proposals...
>>
>> 								Honza
>>
>
> The conclusion from the CMA session last year was that pinned pages need to be
> fixed up at the caller sites doing the pinning. Each caller site really needs
> to be taken individually. I think the discussion last year was good but if
> it's going to end up with a different conclusion I agree there needs to be
> concrete proposals.

But that was not what was suggested in the kvm guest ram pin due to vfio
thread I linked above. I think we still need to have an agreement on
whether the callers should be migrating the pages or a generic framework
like VM_PINNED is needed.

>
> Something that could be worth discussing as well is Joonsoo Kim's proposal for
> page reference tracking http://thread.gmane.org/gmane.linux.kernel.api/16138
>
> Thanks,
> Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
