Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id ABF198E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 12:19:09 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id i189-v6so3259949pge.6
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 09:19:09 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id d127-v6si5266593pfa.189.2018.09.26.09.19.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Sep 2018 09:19:08 -0700 (PDT)
Subject: Re: [PATCH v5 2/4] mm: Provide kernel parameter to allow disabling
 page init poisoning
References: <20180925200551.3576.18755.stgit@localhost.localdomain>
 <20180925201921.3576.84239.stgit@localhost.localdomain>
 <20180926073831.GC6278@dhcp22.suse.cz>
 <c57da51a-009a-9500-4dc5-1d9912e78abd@linux.intel.com>
 <98411844-19b7-a75b-d52c-6e2c46b40d57@intel.com>
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Message-ID: <0845f5c1-5737-3749-69dd-e7fb5d1b75c6@linux.intel.com>
Date: Wed, 26 Sep 2018 09:18:16 -0700
MIME-Version: 1.0
In-Reply-To: <98411844-19b7-a75b-d52c-6e2c46b40d57@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pavel.tatashin@microsoft.com, dave.jiang@intel.com, jglisse@redhat.com, rppt@linux.vnet.ibm.com, dan.j.williams@intel.com, logang@deltatee.com, mingo@kernel.org, kirill.shutemov@linux.intel.com



On 9/26/2018 8:41 AM, Dave Hansen wrote:
> On 09/26/2018 08:24 AM, Alexander Duyck wrote:
>> With no options it works just like slub_debug and enables all
>> available options. So in our case it is a NOP since we wanted the
>> debugging enabled by default.
> 
> Yeah, but slub_debug is different.
> 
> First, nobody uses the slub_debug=- option because *that* is only used
> when you have SLUB_DEBUG=y *and* CONFIG_SLUB_DEBUG_ON=y, which not even
> Fedora does.
> 
> slub_debug is *primarily* for *adding* debug features.  For this, we
> need to turn them off.
> 
> It sounds like following slub_debug was a bad idea, especially following
> its semantics too closely when it doesn't make sense.

I actually like the idea of using slub_debug style semantics. It makes 
sense when you start thinking about future features being added. Then we 
might actually have scenarios where vm_debug=P will make sense, but for 
right now it is probably not going to be used. Basically this all makes 
room for future expansion. It is just ugly to read right now while we 
only have one feature controlled by this bit.
