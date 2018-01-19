Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 86BA16B0069
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 00:14:08 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id e4so402443ote.7
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 21:14:08 -0800 (PST)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id w13si4279559oth.212.2018.01.18.21.14.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jan 2018 21:14:07 -0800 (PST)
Subject: Re: [LSF/MM TOPIC] CAPI/CCIX cache coherent device memory (NUMA too
 ?)
References: <20180116210321.GB8801@redhat.com>
 <CAKTCnznQ95Ao5hOEH=pecaoU9G9xYvitV64shf8S39vzfH+uyA@mail.gmail.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <8493581b-3e1b-1a61-00b2-59cebb1af452@nvidia.com>
Date: Thu, 18 Jan 2018 21:14:05 -0800
MIME-Version: 1.0
In-Reply-To: <CAKTCnznQ95Ao5hOEH=pecaoU9G9xYvitV64shf8S39vzfH+uyA@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>, Jerome Glisse <jglisse@redhat.com>
Cc: lsf-pc <lsf-pc@lists.linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, Jonathan Masters <jcm@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On 01/17/2018 08:29 AM, Balbir Singh wrote:
> On Wed, Jan 17, 2018 at 2:33 AM, Jerome Glisse <jglisse@redhat.com> wrote:
>> CAPI (on IBM Power8 and 9) and CCIX are two new standard that
>> build on top of existing interconnect (like PCIE) and add the
>> possibility for cache coherent access both way (from CPU to
>> device memory and from device to main memory). This extend
>> what we are use to with PCIE (where only device to main memory
>> can be cache coherent but not CPU to device memory).
>>
>> How is this memory gonna be expose to the kernel and how the
>> kernel gonna expose this to user space is the topic i want to
>> discuss. I believe this is highly device specific for instance
>> for GPU you want the device memory allocation and usage to be
>> under the control of the GPU device driver. Maybe other type
>> of device want different strategy.
>>
>> The HMAT patchset is partialy related to all this as it is about
>> exposing different type of memory available in a system for CPU
>> (HBM, main memory, ...) and some of their properties (bandwidth,
>> latency, ...).
>>
>>
>> We can start by looking at how CAPI and CCIX plan to expose this
>> to the kernel and try to list some of the type of devices we
>> expect to see. Discussion can then happen on how to represent this
>> internaly to the kernel and how to expose this to userspace.
>>
>> Note this might also trigger discussion on a NUMA like model or
>> on extending/replacing it by something more generic.
>>
> 
> Yes, I agree. I've had some experience with both NUMA and HMM/CDM
> models. I think we should compare and contrast the trade-offs
> and also discuss how we want to expose some of the ZONE_DEVICE
> information back to user space.

Hi Jerome and all,

Thanks for adding me here. This area is something I'm interested in,
and would love to get a chance to discuss some more. 

There are a lot of new types of computers popping up, with a remarkable
variety of memory-like components (and some unusual direct connections 
between components), even within the same box. It really is getting
interesting. 

I recall some key points from last year's discussions very clearly, 
about doing careful experiments (for example, add HMM, and see how it's 
used, rather than making large NUMA changes right away).  So now that
we are (just barely) getting some experience with NUMA and HMM systems, 
maybe we can look a bit further ahead. Admittedly, not much further; as  
noted on the other thread ("HMM status upstream"), there is still ongoing
effort to finish up various device drivers, and get together an open source 
compute stack.


thanks,
-- 
John Hubbard
NVIDIA

> 
>>
>> Peoples (alphabetical order on first name) sorry if i missed
>> anyone:
>>     "Anshuman Khandual" <khandual@linux.vnet.ibm.com>
>>     "Balbir Singh" <bsingharora@gmail.com>
>>     "Dan Williams" <dan.j.williams@intel.com>
>>     "John Hubbard" <jhubbard@nvidia.com>
>>     "Jonathan Masters" <jcm@redhat.com>
>>     "Ross Zwisler" <ross.zwisler@linux.intel.com>
> 
> I'd love to be there if invited.
> 
> Thanks,
> Balbir Singh.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
