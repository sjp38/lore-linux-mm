Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 33AEE6B0511
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 05:05:27 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id y14so2453858wrd.3
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 02:05:27 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i3si900072wmd.249.2017.08.25.02.05.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 25 Aug 2017 02:05:25 -0700 (PDT)
Subject: Re: [RESEND PATCH 0/3] mm: Add cache coloring mechanism
References: <20170823100205.17311-1-lukasz.daniluk@intel.com>
 <f95eacd5-0a91-24a0-7722-b63f3c196552@suse.cz>
 <82cc1886-6c24-4e6e-7269-4d150e9f39eb@intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <88c17eaf-7546-8cd8-0404-3a4a7aafddee@suse.cz>
Date: Fri, 25 Aug 2017 11:04:23 +0200
MIME-Version: 1.0
In-Reply-To: <82cc1886-6c24-4e6e-7269-4d150e9f39eb@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, =?UTF-8?Q?=c5=81ukasz_Daniluk?= <lukasz.daniluk@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: lukasz.anaczkowski@intel.com

On 08/24/2017 06:08 PM, Dave Hansen wrote:
> On 08/24/2017 05:47 AM, Vlastimil Babka wrote:
>> So the obvious question, what about THPs? Their size should be enough to
>> contain all the colors with current caches, no? Even on KNL I didn't
>> find more than "32x 1 MB 16-way L2 caches". This is in addition to the
>> improved TLB performance, which you want to get as well for such workloads?
> 
> The cache in this case is "MCDRAM" which is 16GB in size.  It can be
> used as normal RAM or a cache.  This patch deals with when "MCDRAM" is
> in its cache mode.

Hm, 16GB direct mapped, that means 8k colors for 2MB THP's. Is that
really practical? Wouldn't such workload use 1GB hugetlbfs pages? Then
it's still 16 colors to manage, but could be done purely in userspace
since they should not move in physical memory and userspace can control
where to map each phase in the virtual layout.

> It's described in the "Memory Modes" slide here:
> 
>> http://www.nersc.gov/users/computational-systems/cori/configuration/knl-processor-modes/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
