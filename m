Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 247E98E00A4
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 16:49:09 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id x19-v6so13302831pfh.15
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 13:49:09 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id q4-v6si3388817pgj.417.2018.09.25.13.49.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Sep 2018 13:49:07 -0700 (PDT)
Subject: Re: [PATCH v5 2/4] mm: Provide kernel parameter to allow disabling
 page init poisoning
References: <20180925200551.3576.18755.stgit@localhost.localdomain>
 <20180925201921.3576.84239.stgit@localhost.localdomain>
 <13285e05-fb90-b948-6f96-777f94079657@intel.com>
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Message-ID: <8faf3acc-e47e-8ef9-a1a0-c0d6ebfafa1e@linux.intel.com>
Date: Tue, 25 Sep 2018 13:38:43 -0700
MIME-Version: 1.0
In-Reply-To: <13285e05-fb90-b948-6f96-777f94079657@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org
Cc: pavel.tatashin@microsoft.com, mhocko@suse.com, dave.jiang@intel.com, jglisse@redhat.com, rppt@linux.vnet.ibm.com, dan.j.williams@intel.com, logang@deltatee.com, mingo@kernel.org, kirill.shutemov@linux.intel.com



On 9/25/2018 1:26 PM, Dave Hansen wrote:
> On 09/25/2018 01:20 PM, Alexander Duyck wrote:
>> +	vm_debug[=options]	[KNL] Available with CONFIG_DEBUG_VM=y.
>> +			May slow down system boot speed, especially when
>> +			enabled on systems with a large amount of memory.
>> +			All options are enabled by default, and this
>> +			interface is meant to allow for selectively
>> +			enabling or disabling specific virtual memory
>> +			debugging features.
>> +
>> +			Available options are:
>> +			  P	Enable page structure init time poisoning
>> +			  -	Disable all of the above options
> 
> Can we have vm_debug=off for turning things off, please?  That seems to
> be pretty standard.

No. The simple reason for that is that you had requested this work like 
the slub_debug. If we are going to do that then each individual letter 
represents a feature. That is why the "-" represents off. We cannot have 
letters represent flags, and letters put together into words. For 
example slub_debug=OFF would turn on sanity checks and turn off 
debugging for caches that would have causes higher minimum slab orders.

Either I can do this as a single parameter that supports on/off 
semantics, or I can support it as a slub_debug type parameter that does 
flags based on the input options. I would rather not muddy things by 
trying to do both.

> Also, we need to document the defaults.  I think the default is "all
> debug options are enabled", but it would be nice to document that.

In the description I call out "All options are enabled by default, and 
this interface is meant to allow for selectively enabling or disabling".
