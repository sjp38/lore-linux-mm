Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2F33B6B0069
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 07:50:26 -0500 (EST)
Received: by mail-vk0-f72.google.com with SMTP id w194so99923596vkw.2
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 04:50:26 -0800 (PST)
Received: from mail-vk0-x242.google.com (mail-vk0-x242.google.com. [2607:f8b0:400c:c05::242])
        by mx.google.com with ESMTPS id 102si17215vkq.139.2016.12.01.04.50.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 04:50:25 -0800 (PST)
Received: by mail-vk0-x242.google.com with SMTP id x186so10693429vkd.2
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 04:50:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <885a17ba-fed8-e312-c2d3-e28a996f5424@linux.vnet.ibm.com>
References: <20161018150243.GZ3117@twins.programming.kicks-ass.net>
 <cover.1479465699.git.ldufour@linux.vnet.ibm.com> <871sy8284n.fsf@tassilo.jf.intel.com>
 <885a17ba-fed8-e312-c2d3-e28a996f5424@linux.vnet.ibm.com>
From: Balbir Singh <bsingharora@gmail.com>
Date: Thu, 1 Dec 2016 23:50:24 +1100
Message-ID: <CAKTCnz=0QZ55L5=WbLoCQwB8sXZ_2dgqrBCgdtt=jCqejy=wHA@mail.gmail.com>
Subject: Re: [RFC PATCH v2 0/7] Speculative page faults
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Andi Kleen <andi@firstfloor.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, Peter Zijlstra <peterz@infradead.org>, Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>

On Thu, Dec 1, 2016 at 7:34 PM, Laurent Dufour
<ldufour@linux.vnet.ibm.com> wrote:
> On 18/11/2016 15:08, Andi Kleen wrote:
>> Laurent Dufour <ldufour@linux.vnet.ibm.com> writes:
>>
>>> This is a port on kernel 4.8 of the work done by Peter Zijlstra to
>>> handle page fault without holding the mm semaphore.
>>
>> One of the big problems with patches like this today is that it is
>> unclear what mmap_sem actually protects. It's a big lock covering lots
>> of code. Parts in the core VM, but also do VM callbacks in file systems
>> and drivers rely on it too?
>>
>> IMHO the first step is a comprehensive audit and then writing clear
>> documentation on what it is supposed to protect. Then based on that such
>> changes can be properly evaluated.
>
> Hi Andi,
>
> Sorry for the late answer...
>
> I do agree, this semaphore is massively used and it would be nice to
> have all its usage documented.
>
> I'm currently tracking all the mmap_sem use in 4.8 kernel (about 380
> hits) and I'm trying to identify which it is protecting.
>
> In addition, I think it may be nice to limit its usage to code under mm/
> so that in the future it may be easier to find its usage.

Is this possible? All sorts of arch's fault
handling/virtualization/file system and drivers (IO/DRM/) hold
mmap_sem.

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
