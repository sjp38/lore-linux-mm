Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C82016B0005
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 13:09:48 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 5so6878404wrb.15
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 10:09:48 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r4si5088006wrg.527.2018.03.02.10.09.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 02 Mar 2018 10:09:47 -0800 (PST)
Subject: Re: [PATCH v4 3/3] mm/free_pcppages_bulk: prefetch buddy while not
 holding lock
References: <20180301062845.26038-1-aaron.lu@intel.com>
 <20180301062845.26038-4-aaron.lu@intel.com>
 <20180301140044.GK15057@dhcp22.suse.cz>
 <cb158b3d-c992-6679-24df-b37d2bb170e0@suse.cz>
 <2433e857-fea7-9af4-d124-538ad17de454@intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <787e53b9-20d3-a2df-44fc-ea8c31a6ced3@suse.cz>
Date: Fri, 2 Mar 2018 19:08:00 +0100
MIME-Version: 1.0
In-Reply-To: <2433e857-fea7-9af4-d124-538ad17de454@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Michal Hocko <mhocko@kernel.org>, Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, David Rientjes <rientjes@google.com>

On 03/02/2018 07:00 PM, Dave Hansen wrote:
> On 03/02/2018 09:55 AM, Vlastimil Babka wrote:
>> It's even stranger to me. Struct page is 64 bytes these days, exactly a
>> a cache line. Unless that changed, Intel CPUs prefetched a "buddy" cache
>> line (that forms an aligned 128 bytes block with the one we touch).
> 
> I believe that was a behavior that was specific to the Pentium 4
> "Netburst" era.  I don't think the 128-byte line behavior exists on
> modern Intel cpus.

I remember it on Core 2 something (Nehalem IIRC). And this page suggests
up to Broadwell, and it can be disabled. And it's an L2 prefetcher indeed.
https://software.intel.com/en-us/articles/disclosure-of-hw-prefetcher-control-on-some-intel-processors


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
