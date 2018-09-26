Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4E9CB8E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 11:25:22 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id d40-v6so10891882pla.14
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 08:25:22 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id w15-v6si5151960pgc.366.2018.09.26.08.25.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Sep 2018 08:25:21 -0700 (PDT)
Subject: Re: [PATCH v5 2/4] mm: Provide kernel parameter to allow disabling
 page init poisoning
References: <20180925200551.3576.18755.stgit@localhost.localdomain>
 <20180925201921.3576.84239.stgit@localhost.localdomain>
 <20180926073831.GC6278@dhcp22.suse.cz>
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Message-ID: <c57da51a-009a-9500-4dc5-1d9912e78abd@linux.intel.com>
Date: Wed, 26 Sep 2018 08:24:56 -0700
MIME-Version: 1.0
In-Reply-To: <20180926073831.GC6278@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pavel.tatashin@microsoft.com, dave.jiang@intel.com, dave.hansen@intel.com, jglisse@redhat.com, rppt@linux.vnet.ibm.com, dan.j.williams@intel.com, logang@deltatee.com, mingo@kernel.org, kirill.shutemov@linux.intel.com

On 9/26/2018 12:38 AM, Michal Hocko wrote:
> On Tue 25-09-18 13:20:12, Alexander Duyck wrote:
> [...]
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
> I agree with Dave that this is confusing as hell. So what does vm_debug
> (without any options means). I assume it's NOP and all debugging is
> enabled and that is the default. What if I want to disable _only_ the
> page struct poisoning. The weird lookcing `-' will disable all other
> options that we might gather in the future.

With no options it works just like slub_debug and enables all available 
options. So in our case it is a NOP since we wanted the debugging 
enabled by default.

> Why cannot you simply go with [no]vm_page_poison[=on/off]?

That is what I had to begin with, but Dave Hansen and Dan Williams 
suggested that I go with a slub_debug style interface so we could extend 
it in the future.

It would probably make more sense if we had additional options added, 
but we only have one option for now so the only values we really have 
are 'P' and '-' for now.
