Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 293118E0001
	for <linux-mm@kvack.org>; Fri, 28 Dec 2018 08:31:18 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id g12so18323642pll.22
        for <linux-mm@kvack.org>; Fri, 28 Dec 2018 05:31:18 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id c13si19996495pgi.531.2018.12.28.05.31.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Dec 2018 05:31:16 -0800 (PST)
Date: Fri, 28 Dec 2018 21:31:11 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH v2 00/21] PMEM NUMA node and hotness
 accounting/migration
Message-ID: <20181228133111.zromvopkfcg3m5oy@wfg-t540p.sh.intel.com>
References: <20181226131446.330864849@intel.com>
 <20181227203158.GO16738@dhcp22.suse.cz>
 <20181228050806.ewpxtwo3fpw7h3lq@wfg-t540p.sh.intel.com>
 <20181228084105.GQ16738@dhcp22.suse.cz>
 <20181228094208.7lgxhha34zpqu4db@wfg-t540p.sh.intel.com>
 <20181228121515.GS16738@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20181228121515.GS16738@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Fan Du <fan.du@intel.com>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

>> > I haven't looked at the implementation yet but if you are proposing a
>> > special cased zone lists then this is something CDM (Coherent Device
>> > Memory) was trying to do two years ago and there was quite some
>> > skepticism in the approach.
>>
>> It looks we are pretty different than CDM. :)
>> We creating new NUMA nodes rather than CDM's new ZONE.
>> The zonelists modification is just to make PMEM nodes more separated.
>
>Yes, this is exactly what CDM was after. Have a zone which is not
>reachable without explicit request AFAIR. So no, I do not think you are
>too different, you just use a different terminology ;)

Got it. OK.. The fall back zonelists patch does need more thoughts.

In long term POV, Linux should be prepared for multi-level memory.
Then there will arise the need to "allocate from this level memory".
So it looks good to have separated zonelists for each level of memory.  

On the other hand, there will also be page allocations that don't care
about the exact memory level. So it looks reasonable to expect
different kind of fallback zonelists that can be selected by NUMA policy.

Thanks,
Fengguang
