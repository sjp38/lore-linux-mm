Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 028C36B000E
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 13:00:28 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id d5so2795428pfn.12
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 10:00:27 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id bj2-v6si5117666plb.286.2018.03.02.10.00.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Mar 2018 10:00:27 -0800 (PST)
Subject: Re: [PATCH v4 3/3] mm/free_pcppages_bulk: prefetch buddy while not
 holding lock
References: <20180301062845.26038-1-aaron.lu@intel.com>
 <20180301062845.26038-4-aaron.lu@intel.com>
 <20180301140044.GK15057@dhcp22.suse.cz>
 <cb158b3d-c992-6679-24df-b37d2bb170e0@suse.cz>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <2433e857-fea7-9af4-d124-538ad17de454@intel.com>
Date: Fri, 2 Mar 2018 10:00:24 -0800
MIME-Version: 1.0
In-Reply-To: <cb158b3d-c992-6679-24df-b37d2bb170e0@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, David Rientjes <rientjes@google.com>

On 03/02/2018 09:55 AM, Vlastimil Babka wrote:
> It's even stranger to me. Struct page is 64 bytes these days, exactly a
> a cache line. Unless that changed, Intel CPUs prefetched a "buddy" cache
> line (that forms an aligned 128 bytes block with the one we touch).

I believe that was a behavior that was specific to the Pentium 4
"Netburst" era.  I don't think the 128-byte line behavior exists on
modern Intel cpus.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
