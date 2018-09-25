Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C794E8E00A4
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 18:28:07 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id n17-v6so13262947pff.17
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 15:28:07 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id e4-v6si3485280pgk.630.2018.09.25.15.28.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Sep 2018 15:28:06 -0700 (PDT)
Subject: Re: [PATCH v5 2/4] mm: Provide kernel parameter to allow disabling
 page init poisoning
References: <20180925200551.3576.18755.stgit@localhost.localdomain>
 <20180925201921.3576.84239.stgit@localhost.localdomain>
 <13285e05-fb90-b948-6f96-777f94079657@intel.com>
 <8faf3acc-e47e-8ef9-a1a0-c0d6ebfafa1e@linux.intel.com>
 <75dde720-c997-51a4-d2e2-8b08eb201550@intel.com>
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Message-ID: <61358149-b233-6194-adcf-2c16b9112fd7@linux.intel.com>
Date: Tue, 25 Sep 2018 15:27:59 -0700
MIME-Version: 1.0
In-Reply-To: <75dde720-c997-51a4-d2e2-8b08eb201550@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org
Cc: pavel.tatashin@microsoft.com, mhocko@suse.com, dave.jiang@intel.com, jglisse@redhat.com, rppt@linux.vnet.ibm.com, dan.j.williams@intel.com, logang@deltatee.com, mingo@kernel.org, kirill.shutemov@linux.intel.com



On 9/25/2018 3:14 PM, Dave Hansen wrote:
> On 09/25/2018 01:38 PM, Alexander Duyck wrote:
>> On 9/25/2018 1:26 PM, Dave Hansen wrote:
>>> On 09/25/2018 01:20 PM, Alexander Duyck wrote:
>>>> +A A A  vm_debug[=options]A A A  [KNL] Available with CONFIG_DEBUG_VM=y.
>>>> +A A A A A A A A A A A  May slow down system boot speed, especially when
>>>> +A A A A A A A A A A A  enabled on systems with a large amount of memory.
>>>> +A A A A A A A A A A A  All options are enabled by default, and this
>>>> +A A A A A A A A A A A  interface is meant to allow for selectively
>>>> +A A A A A A A A A A A  enabling or disabling specific virtual memory
>>>> +A A A A A A A A A A A  debugging features.
>>>> +
>>>> +A A A A A A A A A A A  Available options are:
>>>> +A A A A A A A A A A A A A  PA A A  Enable page structure init time poisoning
>>>> +A A A A A A A A A A A A A  -A A A  Disable all of the above options
>>>
>>> Can we have vm_debug=off for turning things off, please?A  That seems to
>>> be pretty standard.
>>
>> No. The simple reason for that is that you had requested this work like
>> the slub_debug. If we are going to do that then each individual letter
>> represents a feature. That is why the "-" represents off. We cannot have
>> letters represent flags, and letters put together into words. For
>> example slub_debug=OFF would turn on sanity checks and turn off
>> debugging for caches that would have causes higher minimum slab orders.
> 
> We don't have to have the same letters mean the same things for both
> options.  We also can live without 'o' and 'f' being valid.  We can
> *also* just say "don't do 'off'" if you want to enable things.

I'm not saying we do either. I would prefer it if we stuck to similar 
behavior though. If we are going to do a slub_debug style parameter then 
we should stick with similar behavior where "-" is used to indicate all 
features off.

> I'd much rather have vm_debug=off do the right thing than have
> per-feature enable/disable.  I know I'll *never* remember vm_debug=- and
> doing it this way will subject me to innumerable trips to Documentation/
> during my few remaining years.
> 
> Surely you can make vm_debug=off happen. :)

I could, but then it is going to confuse people even more. I really feel 
that if we want to do a slub_debug style interface we should use the 
same switch for turning off all the features that they do for slub_debug.

>>> we need to document the defaults.A  I think the default is "all
>>> debug options are enabled", but it would be nice to document that.
>>
>> In the description I call out "All options are enabled by default, and this interface is meant to allow for selectively enabling or disabling".
> 
> I found "all options are enabled by default" really confusing.  Maybe:
> 
> "Control debug features which become available when CONFIG_DEBUG_VM=y.
> When this option is not specified, all debug features are enabled.  Use
> this option enable a specific subset."
> 
> Then, let's actually say what the options do, and what their impact is:
> 
> 	P	Enable 'struct page' poisoning at initialization.
> 		(Slows down boot time).
>

 From my perspective I just don't see how this changes much since it 
conveys the same message I had conveyed in my description. Since it 
looks like Andrew applied the patch feel free to submit your suggestion 
here as a follow-up patch and I would be willing to review/ack it.
