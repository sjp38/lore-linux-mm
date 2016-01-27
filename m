Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id DEA476B0253
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 14:08:02 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id n5so43365215wmn.1
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 11:08:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z133si12756490wmg.61.2016.01.27.11.08.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Jan 2016 11:08:01 -0800 (PST)
Subject: Re: [Lsf-pc] [LSF/MM ATTEND] 2016: Requests to attend MM-summit
References: <87k2n2usyf.fsf@linux.vnet.ibm.com>
 <20160122201707.1271a279@cotter.ozlabs.ibm.com>
 <20160122141948.GG16898@quack.suse.cz> <56A2725B.1090509@redhat.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56A9158C.60604@suse.cz>
Date: Wed, 27 Jan 2016 20:07:56 +0100
MIME-Version: 1.0
In-Reply-To: <56A2725B.1090509@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>, Jan Kara <jack@suse.cz>, Balbir Singh <bsingharora@gmail.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, Peter Zijlstra <peterz@infradead.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 01/22/2016 07:18 PM, Laura Abbott wrote:
> On 01/22/2016 06:19 AM, Jan Kara wrote:
>> On Fri 22-01-16 20:17:07, Balbir Singh wrote:
>>> On Fri, 22 Jan 2016 10:11:12 +0530
>>> "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
>>>
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
> 
> Something that could be worth discussing as well is Joonsoo Kim's proposal for
> page reference tracking http://thread.gmane.org/gmane.linux.kernel.api/16138

I think indentifying the pinners and actually doing something about them, are
different things. The tracking might help with the identification. Maybe some
pins can be removed as found to be unneeded, but VM_PINNED infrastructure should
help with dealing with the genuine ones - IIRC the idea was that prior to
(relatively long-term) pinning, the pages would be migrated away from MOVABLE or
CMA pageblocks to reduce fragmentation/allow CMA allocations succeed. Otherwise
the only other option I see for genuine long-term pins is to pre-emptively
allocate such pages as UNMOVABLE. A waste in case it's a large class of pages
where only a subset of them (not known upfront) is going to be pinned. What if
the class is e.g. "userspace-mapped pages"?


> Thanks,
> Laura
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
